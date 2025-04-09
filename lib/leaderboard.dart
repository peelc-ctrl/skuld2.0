import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaderboardPage extends StatefulWidget {
  final String currentUsername; // Pass this from your login

  const LeaderboardPage({super.key, required this.currentUsername});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<dynamic> leaderboard = [];
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    final response = await http.get(Uri.parse('http://your-backend.com/api/leaderboard/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        leaderboard = data;
        final found = data.firstWhere(
          (user) => user['username'] == widget.currentUsername,
          orElse: () => {},
        );
        currentUser = found.isNotEmpty ? found : null;
      });
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }

  Widget _buildMedalIcon(int rank) {
    switch (rank) {
      case 1:
        return Icon(Icons.emoji_events, color: Colors.amber, size: 28);
      case 2:
        return Icon(Icons.emoji_events, color: Colors.grey, size: 24);
      case 3:
        return Icon(Icons.emoji_events, color: Colors.brown, size: 22);
      default:
        return CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Text(rank.toString()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: leaderboard.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final user = leaderboard[index];
                      final rank = index + 1;
                      final isCurrentUser = user['username'] == widget.currentUsername;

                      return Card(
                        color: isCurrentUser ? Colors.deepPurple[200] : Colors.white10,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: _buildMedalIcon(rank),
                          title: Text(
                            user['username'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: Text(
                            '${user['score']} pts',
                            style: const TextStyle(color: Colors.amberAccent),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (currentUser != null && !leaderboard.any((u) => u['username'] == widget.currentUsername))
                  Container(
                    color: Colors.deepPurple[300],
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Your Rank: ${currentUser!['rank']} - ${currentUser!['score']} pts',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
    );
  }
}
