import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Function to handle login
  Future<void> _login() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final email = _emailController.text;
    final password = _passwordController.text;

    print("Attempting login for: $email");

    final success = await AuthService().loginUser(email, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      print("Login successful, fetching profile...");
      final profile = await AuthService().getUserProfile();
      print("Profile response: $profile");

      if (profile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome ${profile['username']}!')),
        );

        print("Navigating to /home...");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("Profile is null!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch profile')),
        );
      }
    } else {
      print("Login failed");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed. Please check your credentials.')),
      );
    }
  } catch (e, stacktrace) {
    print("Exception during login: $e");
    print(stacktrace);
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/landing');
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email input field (Username)
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),

            // Password input field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),

            // Show loading spinner or login button
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login, // Login action
                    child: Text("Login"),
                  ),
            SizedBox(height: 10),

            // Button to navigate to account creation
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/createAccount");
              },
              child: Text("Create an account"),
            ),
          ],
        ),
      ),
    );
  }
}
