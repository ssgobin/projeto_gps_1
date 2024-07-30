import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class OSRMService {
  final Dio _dio = Dio();

  Future<List<LatLng>> getRoute(List<LatLng> points) async {
    final coordinates = points.map((point) => '${point.longitude},${point.latitude}').join(';');
    final url = 'http://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson';
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> coords = data['routes'][0]['geometry']['coordinates'];
      return coords.map((coord) => LatLng(coord[1], coord[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }
}
