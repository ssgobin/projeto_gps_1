import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_gps_1/widgets/map_widget.dart';

class JoinGroupScreen extends StatelessWidget {
  final String groupId;

  const JoinGroupScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrar no Grupo'),
      ),
      body: Center(
        child: Text('ID do Grupo: $groupId'),
      ),
    );
  }
}

class GroupsListScreen extends StatefulWidget {
  @override
  _GroupsListScreenState createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<String>> _getUserGroups() async {
    if (user == null) return [];

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final userData = userDoc.data();
    final groupIds = List<String>.from(userData?['groups'] ?? []);

    return groupIds;
  }

  Future<void> _leaveGroup(BuildContext context, String groupId) async {
    if (user == null) return;

    final userId = user!.uid;

    // Remove o grupo da lista de grupos do usuário
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'groups': FieldValue.arrayRemove([groupId]),
    });

    // Remove o usuário do grupo
    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Você saiu do grupo!')),
    );

    setState(() {
      // Atualiza a interface do usuário
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listar Grupos'),
      ),
      body: FutureBuilder<List<String>>(
        future: _getUserGroups(),
        builder: (context, userGroupsSnapshot) {
          if (userGroupsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userGroupsSnapshot.hasData || userGroupsSnapshot.data!.isEmpty) {
            return Center(child: Text('Você não está em nenhum grupo.'));
          }

          final userGroupIds = userGroupsSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('groups').snapshots(),
            builder: (context, groupsSnapshot) {
              if (!groupsSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final groups = groupsSnapshot.data!.docs.where((doc) {
                final groupId = doc.id;
                return userGroupIds.contains(groupId);
              }).toList();

              if (groups.isEmpty) {
                return Center(child: Text('Você não está em nenhum grupo.'));
              }

              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index].data() as Map<String, dynamic>;
                  final groupId = groups[index].id;

                  return ListTile(
                    title: Text(group['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await _leaveGroup(context, groupId);
                          },
                          child: Text('Sair'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MapWidget(groupId: groupId),
                              ),
                            );
                          },
                          child: Text('Ver'),
                        ),
                      ],
                    ),
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
