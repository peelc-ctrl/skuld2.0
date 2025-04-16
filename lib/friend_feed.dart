import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'follow_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _incomingRequests = [];
  bool _isLoading = false;
  String _error = '';
  Map<String, String> _followStatus = {}; // username -> status

  @override
  void initState() {
    super.initState();
    _loadIncomingRequests();
  }

  Future<void> _loadIncomingRequests() async {
    final requests = await FollowService.getIncomingFollowRequests();
    setState(() {
      _incomingRequests = requests;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
      _followStatus = {};
    });

    String? accessToken = await AuthService().getAccessToken();
    if (accessToken == null) {
      setState(() {
        _error = 'Failed to retrieve access token';
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse('http://192.168.1.84:8000/api/users/?search=$query');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> users = decoded['data'];

      final currentUsername = await AuthService().getCurrentUsername();
      if (currentUsername == null) {
        setState(() {
          _error = 'Unable to fetch current username';
        });
        return;
      }

      for (var user in users) {
        String username = user['username'];
        if (username == currentUsername) continue;

        bool isFollowing = await FollowService.isFollowing(currentUsername, username);
        setState(() {
          _followStatus[username] = isFollowing ? 'following' : 'not_following';
        });
      }

      setState(() {
        _searchResults = users;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Failed to load users';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleFollow(String username) async {
    bool success = await FollowService.sendFollowRequest(username);
    if (success) {
      setState(() {
        _followStatus[username] = 'requested';
      });
    }
  }

  Future<void> _handleUnfollow(String username) async {
    bool success = await FollowService.unfollowUser(username);
    if (success) {
      setState(() {
        _followStatus[username] = 'not_following';
      });
    }
  }

  Future<void> _acceptFollowRequest(int requestId) async {
    bool success = await FollowService.acceptFollowRequest(requestId);
    if (success) {
      _loadIncomingRequests();
    } else {
      setState(() {
        _error = 'Failed to accept follow request';
      });
    }
  }

  Future<void> _rejectFollowRequest(int requestId) async {
    bool success = await FollowService.rejectFollowRequest(requestId);
    if (success) {
      _loadIncomingRequests();
    } else {
      setState(() {
        _error = 'Failed to reject follow request';
      });
    }
  }

  Widget _buildActionButton(String username, String status) {
    switch (status) {
      case 'following':
        return ElevatedButton(
          onPressed: () => _handleUnfollow(username),
          child: Text('Unfollow'),
        );
      case 'requested':
        return ElevatedButton(
          onPressed: null, // Disabled state for requested follow
          child: Text('Requested'),
        );
      default:
        return ElevatedButton(
          onPressed: () => _handleFollow(username),
          child: Text('Follow'),
        );
    }
  }

  final List<Map<String, dynamic>> _posts = [
    {
      'username': 'KyoujuroRengoku',
      'profilePic': 'assets/rengoku.jpg',
      'workoutType': 'Deadlift',
      'workoutDetails': 'Hit a new PR today! Deadlift 200kg!',
      'comments': [
        {'user': 'ZenitsuAgatsuma', 'comment': 'You got this, Flame Hashira! Keep it up!'},
        {'user': 'InosukeHashibira', 'comment': 'Not bad, but I can lift more!'},
      ],
      'skolCount': 5,
      'timestamp': '2025-04-15 10:00 AM',
    },
    {
      'username': 'ZenitsuAgatsuma',
      'profilePic': 'assets/zenitsu.jpg',
      'workoutType': 'Push-Ups',
      'workoutDetails': 'Maxed out on push-ups today. 100 in a row!',
      'comments': [
        {'user': 'KyoujuroRengoku', 'comment': 'Impressive! Well done, Zenitsu!'},
      ],
      'skolCount': 3,
      'timestamp': '2025-04-14 8:30 AM',
    },
    {
      'username': 'InosukeHashibira',
      'profilePic': 'assets/inosuke.jpg',
      'workoutType': 'Squats',
      'workoutDetails': 'Crushed squats today! 150kg on my back!',
      'comments': [
        {'user': 'ZenitsuAgatsuma', 'comment': 'How do you squat that much? I am amazed!'},
        {'user': 'KyoujuroRengoku', 'comment': 'That’s insane, Inosuke!'},
      ],
      'skolCount': 8,
      'timestamp': '2025-04-13 9:45 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Find Other Vikingr',
          style: GoogleFonts.germaniaOne(
            fontSize: 32,
            color: Color.fromARGB(241, 219, 204, 229),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Search by username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchUsers(_controller.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Follow Requests Section
            if (_incomingRequests.isNotEmpty) ...[
              Text('Follow Requests', style: TextStyle(fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _incomingRequests.length,
                itemBuilder: (context, index) {
                  final request = _incomingRequests[index];
                  final fromUser = request['from_user']['username'];
                  final requestId = request['id'];
                  final profilePicture = request['from_user']['profile_picture'];

                  return ListTile(
                    leading: profilePicture != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(profilePicture),
                          )
                        : CircleAvatar(child: Icon(Icons.account_circle)),
                    title: Text(fromUser),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptFollowRequest(requestId),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectFollowRequest(requestId),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Divider(),
            ],

            // Search Results Section
            if (_isLoading)
              CircularProgressIndicator()
            else if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    final username = user['username'];
                    final status = _followStatus[username] ?? 'not_following';
                    final profilePicture = user['profile_picture'];

                    return ListTile(
                      leading: profilePicture != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(profilePicture),
                            )
                          : CircleAvatar(child: Icon(Icons.account_circle)),
                      title: Text(username),
                      subtitle: Text('${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'),
                      trailing: _buildActionButton(username, status), // Follow button
                    );
                  },
                ),
              ),
            Divider(),

            // Friends Feed Section
            Text('Friends Feed', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(post['profilePic']),
                    ),
                    title: Text(post['username']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['workoutType']),
                        Text(post['workoutDetails']),
                        Row(
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(width: 4),
                            Text(post['timestamp']),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Skol: ${post['skolCount']}'),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



