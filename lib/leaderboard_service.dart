import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // To use SharedPreferences for token storage
import 'leaderboard_entry.dart';

class LeaderboardService {
  static Future<List<LeaderboardEntry>> fetchLeaderboard(String token) async {
    final url = Uri.parse('http://192.168.1.84:8000/api/leaderboard/');

    // Set up headers with the token
    final headers = {
      'Authorization': 'Bearer $token',
    };
    print('Sending request to $url with headers: $headers');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Decode the response body and get the 'data' array
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];

      // Return the leaderboard entries after mapping the 'data' array
      return data.map((entry) => LeaderboardEntry.fromJson(entry)).toList();
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load leaderboard');
    }
  }
}
