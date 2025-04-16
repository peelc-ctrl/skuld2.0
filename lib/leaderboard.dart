import 'package:flutter/material.dart';
import 'leaderboard_entry.dart';
import 'leaderboard_service.dart';
import 'auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<LeaderboardEntry>> leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _loadTokenAndLeaderboard();
  }

  // Method to load token and leaderboard
  Future<void> _loadTokenAndLeaderboard() async {
    final token = await AuthService().getAccessToken(); // Get the token from SharedPreferences
    
    if (token != null) {
      // Fetch leaderboard if token is available
      leaderboardFuture = LeaderboardService.fetchLeaderboard(token);
      setState(() {}); // Refresh the UI after fetching leaderboard data
    } else {
      // Handle the case where token is not available
      print('No token found!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LEADERBOARD',
        style: GoogleFonts.germaniaOne(
          color: Colors.white,
          fontSize: 36,
        )),
        backgroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false // AppBar color
      ),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load leaderboard'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No leaderboard data available.'));
          }

          final leaderboard = snapshot.data!;
          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final entry = leaderboard[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Color.fromARGB(179, 219, 204, 229),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Color.fromARGB(255, 93, 0, 100),
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(color: Color.fromARGB(230, 219, 204, 229), fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    entry.user,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Points: ${entry.points}',
                          style: TextStyle(
                            color: const Color.fromARGB(190, 16, 101, 19),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Workouts: ${entry.workoutsCompleted}',
                          style: TextStyle(
                            color: const Color.fromARGB(179, 121, 61, 226),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
