// task_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' as latlng;

class TaskService {
  static final String baseUrl =
      (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api').replaceFirst(RegExp(r'/$'), '');

  // Get authentication token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Create a new task
  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required double reward,
    required String category,
    required String priority,
    required DateTime dueDate,
    required latlng.LatLng location,
    required String locationName,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'reward': reward,
          'category': category,
          'priority': priority,
          'dueDate': dueDate.toIso8601String(),
          'location': {
            'type': 'Point',
            'coordinates': [location.longitude, location.latitude],
          },
          'locationName': locationName,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to create task',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}