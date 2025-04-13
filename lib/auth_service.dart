import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = 'https://192.168.1.84:8000/api/'; // Replace with your actual API URL

  // Function to fetch user profile using the JWT token
  Future<Map<String, String>?> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      return null; // Token is not available, meaning the user is not logged in
    }

    final response = await http.get(
      Uri.parse('$apiUrl/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return {
        'first_name': responseData['first_name'],
        'last_name': responseData['last_name'],
        'email': responseData['email'],
        'userName': responseData['username']
      };
    } else {
      // Handle error
      return null;
    }
  }
}


// Function to FETCH username 
Future<String> fetchUsername(String token) async {
  final response = await http.get(
    Uri.parse('https://192.168.1.84/api/profile/'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['username'];
  } else {
    throw Exception('Failed to load username');
  }
}
