import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skuld/leaderboard.dart';
import 'auth_service.dart'; //authentication service I created
import 'stats_page.dart';
import 'profile.dart';
import 'friend_feed.dart';
import 'package:intl/intl.dart';
import 'streak_card.dart';
import 'create_workout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Default to Home
  String username = '';
  int streak = 0;
  int longest_streak = 0;
  bool isLoading = true;
  String token = '';
  int completedDays = 0; // Variable to track completed days
  int totalDaysInWeek = 7;
  String progressMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadCompletedDays();
    _setProgressMessage();
  }

  // This will fetch user data (profile)
  void _fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    final profile = await AuthService().getUserProfile();
    if (profile != null) {
      setState(() {
        username = profile['username'] ?? '';
        streak = profile['current_streak'] ?? 0;
        longest_streak = profile['longest_streak'] ?? 0;
        isLoading = false;
        token = profile['access_token'] ?? ''; // Store the token for later use
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load the number of completed days from SharedPreferences
  void _loadCompletedDays() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedDays = prefs.getInt('completedDays') ?? 0; // Get saved completed days
    });
  }

  // Save completed days to SharedPreferences
  void _saveCompletedDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('completedDays', days); // Save the new value
  }

  // Update the progress message based on completed days
  void _setProgressMessage() {
    progressMessage = 'SKOL!! $completedDays of $totalDaysInWeek days done this week!';
  }

  // List of pages for BottomNavigationBar
  List<Widget> get _pages {
    return [
      LeaderboardPage(),
      FriendsPage(),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $username!',
              style: GoogleFonts.germaniaOne(
                textStyle: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            Text(
              progressMessage, // Dynamically loaded progress message
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateWorkoutPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 93, 0, 100),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              label: const Text(
                'LOG WORKOUT',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              icon: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 10),
            AnimatedStreakCard(streakCount: streak, longestStreak: longest_streak),
          ],
        ),
      ),
      StatsPage(),
      ProfilePage(),
    ];
  }

  // Handle Bottom Navigation item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'SKULD',
          style: GoogleFonts.germaniaOne(
            textStyle: TextStyle(fontSize: 45, color: Color.fromARGB(179, 219, 204, 229)),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Add action for workout creation
            },
            color: Color.fromARGB(179, 219, 204, 229),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _pages[_selectedIndex], // Use the selected page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.military_tech_sharp), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Friend Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
        ],
        backgroundColor: Colors.black,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        unselectedItemColor: const Color.fromARGB(179, 219, 204, 229),
        unselectedLabelStyle: TextStyle(color: Color.fromARGB(179, 219, 204, 229)),
        selectedItemColor: Color.fromARGB(255, 93, 0, 100),
        onTap: _onItemTapped,
      ),
    );
  }
}
