import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController(); // Password confirmation
  final tcController = TextEditingController(); // Terms and conditions

  bool _termsAccepted = false; // To check if terms are accepted

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  final url = Uri.parse("http://127.0.0.1:8000/api/auth/register/");
  print("Attempting registration...");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text,
        "name": nameController.text,
        "username": usernameController.text,
        "password": passwordController.text,
        "password2": password2Controller.text,
        "tc": _termsAccepted
        //DO NOT CHANGE THE ORDER OF THIS IT WILL BREAK THE WHOLE PROJECT
      }),
    );

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    // Decode the response body as a map
    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created")),
      );
      Navigator.pushNamed(context, '/login');
    } else {
      // Handle error response properly
      final errorMessage = data['error']?['message'] ?? "Registration failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    print("Error during registration: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connection error")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Email is required" : null,
              ),

              // Name Field
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Username"),
                validator: (v) => v!.isEmpty ? "Username is required" : null,
              ),

               TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Username is required" : null,
              ),

              // Password Field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                validator: (v) => v!.length < 6 ? "Password too short" : null,
              ),

              // Confirm Password Field (password2)
              TextFormField(
                controller: password2Controller,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password"),
                validator: (v) {
                  if (v!.isEmpty) return "Please confirm your password";
                  if (v != passwordController.text) return "Passwords do not match";
                  return null;
                },
              ),

              // Terms and Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (bool? value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                      });
                    },
                  ),
                  Text("I accept the Terms and Conditions"),
                ],
              ),

              SizedBox(height: 20),

              ElevatedButton(onPressed: _register, child: Text("Create Account")),
            ],
          ),
        ),
      ),
    );
  }
}
