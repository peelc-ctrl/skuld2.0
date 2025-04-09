import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _profileData = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final response = await http.get(
      Uri.parse('http://your-backend-url/api/profile/'),
      headers: {
        'Authorization': 'Token your_auth_token', // Replace with your token logic
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _profileData = json.decode(response.body);
      });
    } else {
      // Handle error
    }
  }

  Future<void> updateProfile() async {
    final response = await http.put(
      Uri.parse('http://your-backend-url/api/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token your_auth_token',
      },
      body: json.encode(_profileData),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isEditing = false;
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                updateProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _profileData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    buildTextField('First Name', 'first_name'),
                    buildTextField('Last Name', 'last_name'),
                    buildTextField('Email', 'email'),
                    buildTextField('Bio', 'bio', maxLines: 3),
                    buildTextField('Height (cm)', 'height'),
                    buildTextField('Weight (kg)', 'weight'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextField(String label, String key, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: _profileData[key]?.toString() ?? '',
        enabled: _isEditing,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          _profileData[key] = value;
        },
      ),
    );
  }
}

