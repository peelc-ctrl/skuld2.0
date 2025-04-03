import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'login.dart';
import 'home_page.dart';
import 'create_account.dart';
// Import the LandingPage file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    routes: {
      '/login' : (context) => LoginPage(),
      '/createAccount' : (context) => CreateAccountPage(),
      '/landing' : (context) => LandingPage(),
      '/home' : (context) => HomePage(),
    },
      title: 'My SKULD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 93, 0, 100), // Button color
            foregroundColor: Colors.white, // Text color
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: TextStyle(fontSize: 20))
          )
      ),
      home: LandingPage(), // Set LandingPage as the first screen
    );
  }
}


