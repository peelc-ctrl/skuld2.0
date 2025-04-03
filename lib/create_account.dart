import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // API endpoint URL (replace with your Django server URL)
      String url = "http://127.0.0.1:8000/api/register/";

      // Prepare data to send
      Map<String, String> formData = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "email": emailController.text,
        "username": usernameController.text,
        "dob": dobController.text,
        "height": heightController.text.isNotEmpty ? heightController.text : "0",
        "weight": weightController.text.isNotEmpty ? weightController.text : "0",
      };

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(formData),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Account Created Successfully!")),
          );
          Navigator.pushNamed(context, '/login'); // Redirect to login page
        } else {
          var error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${error['error']}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Network Error: Unable to connect to server")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: "First Name"),
                validator: (value) => value!.isEmpty ? "First Name is required" : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: "Last Name"),
                validator: (value) => value!.isEmpty ? "Last Name is required" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return "Email is required";
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Username"),
                validator: (value) => value!.isEmpty ? "Username is required" : null,
              ),
              TextFormField(
                controller: dobController,
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  hintText: "YYYY-MM-DD",
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) => value!.isEmpty ? "Date of Birth is required" : null,
              ),
              TextFormField(
                controller: heightController,
                decoration: InputDecoration(labelText: "Height (Optional)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: weightController,
                decoration: InputDecoration(labelText: "Weight (Optional)"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
