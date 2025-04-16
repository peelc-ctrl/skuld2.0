import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await AuthService().getUserProfile();
    if (data != null) {
      setState(() {
        profileData = data;
        isLoading = false;
      });
    }
  }

  // Success Dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Profile picture updated successfully."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Error Dialog
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Failed to update profile picture."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Method for uploading profile picture (this is just a placeholder for the actual upload logic)
Future<void> _uploadProfilePicture() async {
  final picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    setState(() {
      isLoading = true;
    });

    // Convert XFile to File
    File imageFile = File(pickedFile.path);

    print("Picked file: ${pickedFile.path}");

    try {
      // Log the file size before uploading
      print("Uploading image...");

      // Call the AuthService upload function
      var response = await AuthService().uploadProfilePicture(imageFile);

      // Log the response status code
      print("Response received with status: ${response.statusCode}");

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        _showSuccessDialog(context);
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog(context);
      }
    } catch (e) {
      // Catch any exceptions
      setState(() {
        isLoading = false;
      });
      print("Error uploading profile picture: $e");
      _showErrorDialog(context);
    }
  } else {
    // Log if no image is picked
    print("No image picked.");
  }
}



  // Concrete implementation of the 'build' method
  @override
  Widget build(BuildContext context) {
    final String baseUrl = 'http://192.168.1.84:8000'; // Your server base URL
    final String? profilePicPath = profileData?['profile_picture'];
    final String? imageUrl =
      (profilePicPath != null && profilePicPath.isNotEmpty)
        ? '$baseUrl$profilePicPath?${DateTime.now().millisecondsSinceEpoch}'
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
         iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Picture
                  GestureDetector(
                    onTap: () {
                      // Trigger image upload here
                      _uploadProfilePicture();
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Color.fromARGB(255, 93, 0, 100),
                          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                          child: imageUrl == null
                              ? const Icon(Icons.person, size: 50, color: Color.fromARGB(179, 219, 204, 229))
                              : null,
                        ),
                        if (imageUrl != null)
                          Icon(
                            Icons.edit,
                            size: 30,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Username
                  Text(
                    "@${profileData?['username'] ?? ''}",
                    style: GoogleFonts.germaniaOne(
                      fontSize: 27,
                      color: Color.fromARGB(231, 219, 204, 229),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Name
                  Text(
                    profileData?['name'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Color.fromARGB(190, 219, 204, 229)),
                  ),

                  const SizedBox(height: 20),

                  // Stats Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat("🔥 Current", profileData?['current_streak'].toString() ?? '0'),
                          _buildStat("🏁 Longest", profileData?['longest_streak'].toString() ?? '0'),
                          _buildStat("⭐ Points", profileData?['total_points'].toString() ?? '0'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Edit Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/editProfile');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 93, 0, 100),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Method to build stat display
  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
