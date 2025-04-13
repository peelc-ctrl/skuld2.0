import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final List<Map<String, dynamic>> _exercises = [];
  final _exerciseController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightsController = TextEditingController();
  
  bool _isBodyweightExercise = false; // New field to track bodyweight status

  DateTime _workoutDate = DateTime.now();

  void _addExercise() {
    if (_exerciseController.text.isEmpty ||
        _setsController.text.isEmpty ||
        _repsController.text.isEmpty ||
        (!_isBodyweightExercise && _weightsController.text.isEmpty)) {
      return;
    }

    final sets = int.tryParse(_setsController.text) ?? 0;
    final weightsInput = _isBodyweightExercise
        ? []
        : _weightsController.text.split(',').map((w) => double.tryParse(w.trim())).toList();

    if (!_isBodyweightExercise && (weightsInput.length != sets || weightsInput.contains(null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid weights for each set.")),
      );
      return;
    }

    setState(() {
      _exercises.add({
        'name': _exerciseController.text,
        'sets': sets,
        'reps': int.tryParse(_repsController.text) ?? 0,
        'weights': weightsInput,
        'isBodyweight': _isBodyweightExercise, // Store the bodyweight status
      });

      _exerciseController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightsController.clear();
      _isBodyweightExercise = false; // Reset checkbox
    });
  }

void _submitWorkout() async {
  final url = Uri.parse('http://192.168.1.84:8000/api/workouts/');

  final workoutData = {
    "date": _workoutDate.toIso8601String(),
    "exercises": _exercises.map((exercise) => {
      "name": exercise['name'],
      "sets": exercise['sets'],
      "reps": exercise['reps'],
      "weights": exercise['weights'],
      "is_bodyweight": exercise['isBodyweight'],
    }).toList(),
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(workoutData),
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Workout Submitted!")),
    );
    Navigator.pop(context);
  } else {
    print("Error: ${response.statusCode}");
    print("Response body: ${response.body}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to submit workout")),
    );
  }
}


  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _workoutDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_workoutDate),
      );

      if (pickedTime != null) {
        setState(() {
          _workoutDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('yMMMd – h:mm a').format(_workoutDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Workout Date:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                TextButton.icon(
                  onPressed: _selectDateTime,
                  icon: const Icon(Icons.calendar_today, color: Colors.white70),
                  label: Text(formattedDate, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Inputs
            TextField(
              controller: _exerciseController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Exercise Name",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Sets",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Reps",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Weights input (Only if not bodyweight)
            if (!_isBodyweightExercise) 
              TextField(
                controller: _weightsController,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Weights per Set (comma separated)",
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 12),

            // Checkbox for bodyweight exercise
            Row(
              children: [
                Checkbox(
                  value: _isBodyweightExercise,
                  onChanged: (value) {
                    setState(() {
                      _isBodyweightExercise = value ?? false;
                    });
                  },
                ),
                const Text(
                  'Bodyweight Exercise',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text("Add Exercise"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  final weights = exercise['weights'].isEmpty
                      ? 'Bodyweight' 
                      : exercise['weights'].join(', ');
                  return Card(
                    color: Colors.deepPurple.shade800,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        exercise['name'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${exercise['sets']} sets x ${exercise['reps']} reps\nWeights: $weights",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: _submitWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
              child: const Text("Finish Workout"),
            ),
          ],
        ),
      ),
    );
  }
}


