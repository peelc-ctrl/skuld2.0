import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Uint8List? imageData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final url = Uri.parse("http://192.168.1.84:8000/api/stats/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final base64Image = data['image'];
        setState(() {
          imageData = base64Decode(base64Image);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load stats");
      }
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Stats")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : imageData != null
                ? Image.memory(imageData!)
                : const Text("No data available"),
      ),
    );
  }
}

