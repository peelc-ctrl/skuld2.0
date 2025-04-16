import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FollowService {
  static const String _baseUrl = 'http://192.168.1.84:8000/api/users';

  /// Send a follow request to a user by username
  static Future<bool> sendFollowRequest(String username) async {
    final token = await AuthService().getAccessToken();
    final uri = Uri.parse('$_baseUrl/$username/follow-request/');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 201;
  }

  /// Unfollow a user by username
  static Future<bool> unfollowUser(String username) async {
    final token = await AuthService().getAccessToken();
    final uri = Uri.parse('$_baseUrl/$username/unfollow');

    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 204;
  }

  /// Check if current user is following the given username
  static Future<bool> isFollowing(String currentUserUsername, String targetUsername) async {
    final token = await AuthService().getAccessToken();
    final uri = Uri.parse('$_baseUrl/follows/$currentUserUsername/');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.any((follow) => follow['following']['username'] == targetUsername);
    }

    return false;
  }

  /// Accept a follow request for a specific user
  static Future<bool> acceptFollowRequest(int requestId) async {
    final token = await AuthService().getAccessToken();
    final uri = Uri.parse('http://192.168.1.84:8000/api/follow-requests/$requestId/');

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': 'accepted', // Assuming you need to update the follow request's status
      }),
    );

    return response.statusCode == 200;
  }

  // Reject a follow request
  static Future<bool> rejectFollowRequest(int requestId) async {
    final token = await AuthService().getAccessToken();
    final uri = Uri.parse('http://192.168.1.84:8000/api/follow-requests/$requestId/');

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': 'rejected',
      }),
    );

    return response.statusCode == 200;
  }

  // Fetch the list of follow requests
  static Future<List<dynamic>> getFollowRequests() async {
    final token = await AuthService().getAccessToken();
    final uri = Uri.parse('$_baseUrl/follow-requests/');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'];
    }

    return [];
  }

  static Future<bool> hasRequestedFollow(String currentUsername, String targetUsername) async {
  final token = await AuthService().getAccessToken();
  if (token == null) return false;

  final response = await http.get(
    Uri.parse('http://192.168.1.84:8000/api/follow-requests/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final requests = decoded['data'] as List<dynamic>;

    // Check if current user sent a request to the target user
    return requests.any((req) =>
      req['from_user']['username'] == currentUsername &&
      req['to_user']['username'] == targetUsername &&
      req['status'] == 'pending'
    );
  } else {
    print('Failed to fetch follow requests: ${response.statusCode}');
    return false;
  }
}

 static Future<List<dynamic>> getIncomingFollowRequests() async {
    final accessToken = await AuthService().getAccessToken();
    final uri = Uri.parse('http://192.168.1.84:8000/api/follow-requests/');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    } else {
      return [];
    }
  }

}

