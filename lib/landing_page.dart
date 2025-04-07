import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mosaic_background.dart'; // Import the mosaic background

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landing Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black
      ),
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         
          MosaicBackground(),

          Container(
            color: Colors.black.withOpacity(0.95), // Adjust overlay opacity
          ),

          // Main content 
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image + Text flush together
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        'assets/skuld_DMNBG.png',
                        width: 600, // Adjust width as needed
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: -8, // Adjust to move text lower
                      child: Text(
                        'SKULD',
                        style: GoogleFonts.germaniaOne(
                          textStyle: TextStyle(fontSize: 70, color: Colors.white), // Fixed color issue
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      child: Text(
                        'Buliding a better Vikingr.',
                        style: TextStyle(fontSize: 14, color:  Color.fromARGB(229, 255, 255, 255)),
                      ),),
                  ],
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login'); // Navigate to LoginPage
                  },
                  child: Text('Login'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/createAccount');
                  },
                  child: Text('Create Account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

