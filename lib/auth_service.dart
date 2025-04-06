import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = 'https://your-django-api.com/api/'; // Replace with your actual API URL

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
      };
    } else {
      // Handle error
      return null;
    }
  }
}
