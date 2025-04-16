import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart'; // for getting MIME type
import 'package:path/path.dart';

class AuthService {


Future<bool> loginUser(String email, String password) async {
  final url = Uri.parse('http://129.161.152.94:8000/api/auth/login/');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);


    

    final access = data['data']['access'] ?? '';
    final refresh = data['data']['refresh'] ?? '';
    final username = data['data']['username'] ?? '';
    final name = data['data']['name'] ?? '';
    final email = data['data']['email'] ?? '';


    if (access != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', access);
      await prefs.setString('refresh_token', refresh);
      await prefs.setString('name', name);
      await prefs.setString('username', username);
      await prefs.setString('email', email);
      return true;
    }
  }

  print("Login failed: ${response.statusCode}");
  print(response.body);
  return false;
  // DO NOT CHANGE THIS IS WORKING!!!
}



Future<Map<String, dynamic>?> getUserProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  if (token == null) {
    print('No access token found');
    return null;
  } else {
    print('Access token found: $token');
  }


  final response = await http.get(
    Uri.parse('http://192.168.1.84:8000/api/auth/profile/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final profileData = jsonDecode(response.body);
    print('Profile data decoded: $profileData');

    await prefs.setString('username', profileData['data']['username'] ?? '');
    await prefs.setString('name', profileData['data']['name'] ?? '');
    return profileData['data'];
  } 
  else {
    print('Failed to fetch profile: ${response.statusCode}');
    print(response.body);
    return null;
  }
}

Future<bool> updateUserProfile(Map<String, String> updatedData) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  final response = await http.put(
    Uri.parse('http://192.168.1.84:8000/api/auth/profile/update/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updatedData),
  );

  return response.statusCode == 200;
}

Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');  // Retrieve token stored during login
  }


    Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');  // Clear token on logout
  }


static Future<bool> createWorkoutSession({
    required String workoutName,
    required String notes,
    required List<Map<String, dynamic>> exercises,
    required DateTime startTime,
    required DateTime endTime,
    required int caloriesBurned,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('Access Token: $token');
    if (token == null) {
      print('No access token found');
      return false;
    }

    final url = Uri.parse('http://192.168.1.84:8000/api/workouts/sessions/');
    final body = jsonEncode({
      'name': workoutName,
      'notes': notes,
      'exercises': exercises,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'calories_burned': caloriesBurned,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Workout created successfully');
      return true;
    } else {
      print('Failed to create workout: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }


  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // Upload profile picture method
  Future<http.Response> uploadProfilePicture(File imageFile) async {
    // Ensure the image file exists
    if (!imageFile.existsSync()) {
      throw Exception('File does not exist');
    }

    // Prepare multipart request
    final uri = Uri.parse('http://192.168.1.84:8000/ap/media/profile/picture/');
    final request = http.MultipartRequest('POST', uri);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // Add token authorization to header
    request.headers['Authorization'] = 'Bearer $token';

    // Add the file as multipart
    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_picture', // Field name expected by the server
        imageFile.path,
        contentType: MediaType('image', 'jpeg'), // Change based on your image type
      ),
    );
    
    

    // Send the request and return the response
    return await http.Client().send(request).then((response) {
      return http.Response.fromStream(response);
    });
  }



}
