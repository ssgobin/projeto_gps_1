import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:projeto_gps_1/services/osrm_service.dart';
import 'package:projeto_gps_1/screens/chat_screen.dart';
import 'package:projeto_gps_1/screens/create_group_screen.dart';

class GroupMembersScreen extends StatelessWidget {
  final String groupId;

  const GroupMembersScreen({Key? key, required this.groupId}) : super(key: key);

  Future<Map<String, String>> _getUserNames(List<String> userIds) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final userNames = <String, String>{};

    for (String userId in userIds) {
      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userNames[userId] = userData['username'] ?? 'Usuário Desconhecido';
      }
    }

    return userNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membros do Grupo'),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final groupData = snapshot.data?.data() as Map<String, dynamic>?;
          if (groupData == null) {
            return Center(child: Text('Erro ao carregar dados do grupo.'));
          }

          final members = List<String>.from(groupData['members'] ?? []);
          final leaderId = groupData['leader'];

          return FutureBuilder<Map<String, String>>(
            future: _getUserNames(members),
            builder: (context, userNamesSnapshot) {
              if (userNamesSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final userNames = userNamesSnapshot.data ?? {};

              return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final userId = members[index];
                  final userName = userNames[userId] ?? 'Usuário Desconhecido';

                  return ListTile(
                    title: Text(userName),
                    trailing: userId == leaderId
                        ? Icon(Icons.flag, color: Colors.red)
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MapWidget extends StatefulWidget {
  final String groupId;

  const MapWidget({Key? key, required this.groupId}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<DocumentSnapshot>? _routeSubscription;
  String? _leaderId;
  Map<String, LatLng> _membersLocations = {};
  Map<String, List<LatLng>> _userRoutes = {};
  Map<String, Color> _memberColors = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
    _subscribeToRouteUpdates();
    _fetchLeader();
    _listenToMembersLocations();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _routeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition!, _mapController.zoom);

        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'latitude': position.latitude,
            'longitude': position.longitude,
          });

          // Atualiza a rota do usuário
          if (_destinationPosition != null) {
            final routePoints = await OSRMService().getRoute([_currentPosition!, _destinationPosition!]);
            setState(() {
              _userRoutes[userId] = routePoints;
            });

            // Atualiza a rota no Firestore
            await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
              'routes': _userRoutes.map((key, value) => MapEntry(key, value.map((point) => {'lat': point.latitude, 'lng': point.longitude}).toList())),
            });
          }
        }
      },
    );
  }

  Future<void> _updateMembersLocations(List<String> members) async {
    final updatedLocations = <String, LatLng>{};
    final updatedRoutes = <String, List<LatLng>>{};

    for (String memberId in members) {
      final memberDoc = await FirebaseFirestore.instance.collection('users').doc(memberId).get();
      if (memberDoc.exists) {
        final memberData = memberDoc.data();
        final LatLng memberLocation = LatLng(memberData!['latitude'], memberData['longitude']);
        updatedLocations[memberId] = memberLocation;

        // Recalcula a rota para o membro
        if (_destinationPosition != null) {
          final routePoints = await OSRMService().getRoute([memberLocation, _destinationPosition!]);
          updatedRoutes[memberId] = routePoints;
        }
      }
    }

    setState(() {
      _membersLocations = updatedLocations;
      _userRoutes = updatedRoutes;
    });
  }

  void _listenToMembersLocations() {
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots().listen((groupSnapshot) {
      final groupData = groupSnapshot.data();
      if (groupData != null && groupData.containsKey('members')) {
        final members = List<String>.from(groupData['members']);
        final updatedLocations = <String, LatLng>{};

        for (String memberId in members) {
          final userDoc = FirebaseFirestore.instance.collection('users').doc(memberId);
          userDoc.snapshots().listen((userSnapshot) {
            final userData = userSnapshot.data();
            if (userData != null && userData.containsKey('latitude') && userData.containsKey('longitude')) {
              final position = LatLng(userData['latitude'], userData['longitude']);
              setState(() {
                updatedLocations[memberId] = position;
              });
            }
          });
        }
      }
    });
  }

  Future<void> _fetchLeader() async {
    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
    final groupData = groupDoc.data();
    if (groupData != null && groupData.containsKey('leader')) {
      setState(() {
        _leaderId = groupData['leader'];
      });
    }
  }

  Future<void> _subscribeToRouteUpdates() async {
    _routeSubscription = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .snapshots()
        .listen((snapshot) {
      final groupData = snapshot.data();
      if (groupData != null && groupData.containsKey('routes')) {
        final routesData = groupData['routes'] as Map<String, dynamic>;
        final userRoutes = routesData.map((key, value) {
          final routePoints = (value as List<dynamic>).map((data) => LatLng(data['lat'], data['lng'])).toList();
          return MapEntry(key, routePoints);
        });

        setState(() {
          _userRoutes = userRoutes;
        });
      }
    });
  }

  Color _generateRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Future<void> _deleteGroup() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != _leaderId) return;

    await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).delete();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa do Grupo'),
        backgroundColor: Colors.purple,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition ?? LatLng(-23.5505, -46.6333),
              zoom: 11.0,
              maxZoom: 18.0,
              minZoom: 8.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      builder: (ctx) => Container(
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ],
                ),
              if (_destinationPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _destinationPosition!,
                      builder: (ctx) => Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ],
                ),
              if (_routePoints.isNotEmpty)
              /*PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      color: Colors.purple,
                    ),
                  ],
                ),*/
              if (_membersLocations.isNotEmpty)
                MarkerLayer(
                  markers: _membersLocations.entries.map((entry) {
                    final memberId = entry.key;
                    final position = entry.value;
                    final color = _memberColors[memberId] ?? Colors.grey;

                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: position,
                      builder: (ctx) => GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Membro do Grupo'),
                              content: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(memberId).get(),
                                builder: (ctx, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (!snapshot.hasData || !snapshot.data!.exists) {
                                    return Text('Usuário Desconhecido');
                                  }
                                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                                  return Text(userData['username'] ?? 'Usuário Desconhecido');
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text('Fechar'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Icon(
                          Icons.directions_car,
                          color: color,
                          size: 40.0,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (_userRoutes.isNotEmpty)
                PolylineLayer(
                  polylines: _userRoutes.entries.where((entry) => entry.key == FirebaseAuth.instance.currentUser?.uid).map((entry) {
                    final userId = entry.key;
                    final routePoints = entry.value;
                    final color = _memberColors[userId] ?? Colors.blue;

                    return Polyline(
                      points: routePoints,
                      strokeWidth: 3.0,
                      color: color,
                    );
                  }).toList(),
                ),
            ],
          ),
          Positioned(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Digite o endereço de destino',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                FloatingActionButton(
                  onPressed: _searchAddress,
                  child: Icon(Icons.search),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              child: Icon(Icons.chat),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ChatScreen(groupId: widget.groupId),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              child: Icon(Icons.group),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => GroupMembersScreen(groupId: widget.groupId),
                  ),
                );
              },
            ),
          ),
          if (FirebaseAuth.instance.currentUser?.uid == _leaderId)
            Positioned(
              bottom: 150,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Excluir Grupo'),
                      content: Text('Tem certeza de que deseja excluir este grupo?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteGroup();
                            Navigator.of(ctx).pop();
                          },
                          child: Text('Excluir'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _searchAddress() async {
    if (_addressController.text.isEmpty) return;

    try {
      final locations = await locationFromAddress(_addressController.text);
      if (locations.isNotEmpty) {
        setState(() {
          _destinationPosition = LatLng(locations.first.latitude, locations.first.longitude);
        });

        // Recalcula a rota para todos os membros
        final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
        final groupData = groupDoc.data();
        if (groupData != null && groupData.containsKey('members')) {
          final members = List<String>.from(groupData['members']);
          final routes = <String, List<LatLng>>{};

          for (String memberId in members) {
            final memberDoc = await FirebaseFirestore.instance.collection('users').doc(memberId).get();
            if (memberDoc.exists) {
              final memberData = memberDoc.data();
              final LatLng memberLocation = LatLng(memberData!['latitude'], memberData['longitude']);
              final routePoints = await OSRMService().getRoute([memberLocation, _destinationPosition!]);
              routes[memberId] = routePoints;
            }
          }

          // Atualiza todas as rotas no Firestore
          await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
            'routes': routes.map((key, value) => MapEntry(key, value.map((point) => {'lat': point.latitude, 'lng': point.longitude}).toList())),
          });

          // Atualiza a rota do usuário atual
          if (_currentPosition != null) {
            final routePoints = await OSRMService().getRoute([_currentPosition!, _destinationPosition!]);
            setState(() {
              _routePoints = routePoints;
            });
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
