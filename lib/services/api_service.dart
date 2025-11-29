import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.100.95:8000'; // IP del dispositivo
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: 'jwt', value: token);
  Future<String?> getToken() => _storage.read(key: 'jwt');
  Future<void> clearToken() => _storage.delete(key: 'jwt');

  Future<Map<String, dynamic>> login(String username, String password) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final token = data['access_token'];
      await saveToken(token);
      return data;
    } else {
      throw Exception('Error en login: ${resp.body}');
    }
  }

  Future<List<Delivery>> getDeliveries() async {
    final token = await getToken();
    final resp = await http.get(
      Uri.parse('$baseUrl/deliveries/assigned'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List;
      return list.map((e) => Delivery.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener entregas: ${resp.body}');
    }
  }

  Future<void> markDelivered({
    required int deliveryId,
    required File photo,
    required double lat,
    required double lon,
    String description = '',
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/deliveries/$deliveryId/deliver');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['lat'] = lat.toString();
    request.fields['lon'] = lon.toString();
    request.fields['description'] = description;
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        photo.path,
        filename: photo.path.split('/').last,
      ),
    );
    final streamed = await request.send();
    final respStr = await streamed.stream.bytesToString();
    if (streamed.statusCode != 200) {
      throw Exception('Error al marcar como entregado: $respStr');
    }
  }
}
