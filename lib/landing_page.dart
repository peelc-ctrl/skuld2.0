import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image + Text flush together
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    'assets/skuld_DMNBG.png',
                    width: 600, // Adjust width as needed
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -1, // Adjust to move text lower
                  child: Text(
                    'SKULD',
                    style: GoogleFonts.germaniaOne(
                      textStyle: TextStyle(fontSize: 70, color: Colors.white), // Fixed color issue
                    ),
                  ),
                ),
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
    );
  }
}



