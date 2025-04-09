import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart'; //authentication service I created
import 'stats_page.dart';
import 'profile.dart';
import 'friend_feed.dart';
import 'streak_card.dart';
import 'create_workout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Default to Home

  //getting the user's name from the database, might change to username
  String firstName = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }
  //getting the user's profile data
  void _fetchUserProfile() async {
    final profile = await AuthService().getUserProfile();
    setState(() {
      if (profile != null){
        firstName = profile['first_name'] ?? 'Freya'; //creates a fallback name if profile not loaded or entered
      }
      isLoading = false;
    });
  }

List<Widget> get _pages {
  return [ 
    
    FriendsFeedPage(),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hello, Dress2Imprez69!', //change to $firstName when backend connected
            style: GoogleFonts.germaniaOne(
              textStyle: TextStyle(fontSize: 30, color: Colors.white))
          ),
          Text(
            '5 of 7 days done this week!',  //dynamically load
            style:TextStyle(fontSize: 15, color: Colors.white)
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: (){
              //add action here!
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddWorkoutPage()));

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 93, 0, 100),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            label: const Text(
              'LOG WORKOUT',
              style: TextStyle(fontSize: 20, color: Colors.white)
            ),
            icon: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 30),
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: (){
              //add action here!
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 93, 0, 100),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            label: const Text(
              'LOG A REST DAY',
              style: TextStyle(fontSize: 20, color: Colors.white)
            ),
            icon: Icon(Icons.bed_rounded, color: Colors.white, size: 30),
          ),
          AnimatedStreakCard(streakCount: 420), //replace with call to database
        ],

      ),
    ),
    StatsPage(),
    ProfilePage(),
  ];
}
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
            textStyle: TextStyle(fontSize: 45, color: Color.fromARGB(179, 219, 204, 229)),)
          ),
          
        automaticallyImplyLeading: false, //makes the add button first and no back
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed:() {
              //add action to go to create a workout or log 
              //workout
            },
              color: Color.fromARGB(179, 219, 204, 229)
            ),
        ]
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
