import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'auth_service.dart';

class CreateWorkoutPage extends StatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  _CreateWorkoutPageState createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  String workoutName = '';
  String notes = '';
  List<WorkoutExerciseEntry> exercises = [WorkoutExerciseEntry()];
  DateTime? startTime;
  DateTime? endTime;
  int caloriesBurned = 0;

  void addExercise() {
    setState(() => exercises.add(WorkoutExerciseEntry()));
  }

  void removeExercise(int index) {
    setState(() => exercises.removeAt(index));
  }

  Future<void> selectDateTime(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final dateTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        setState(() {
          if (isStart) {
            startTime = dateTime;
          } else {
            endTime = dateTime;
          }
        });
      }
    }
  }

  void submitWorkout() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final workoutData = {
        "name": workoutName,
        "notes": notes,
        "exercises": exercises.map((e) => e.toMap()).toList(),
        "start_time": startTime?.toIso8601String(),
        "end_time": endTime?.toIso8601String(),
        "calories_burned": caloriesBurned,
      };

      print('Workout Payload: $workoutData');

      final success = await AuthService.createWorkoutSession(
        workoutName: workoutName,
        notes: notes,
        exercises: exercises.map((e) => e.toMap()).toList(),
        startTime: startTime!,
        endTime: endTime!,
        caloriesBurned: caloriesBurned,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout created!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create workout')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: Text('Create Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Workout Name'),
                onSaved: (value) => workoutName = value ?? '',
                validator: (value) => value!.isEmpty ? 'Enter workout name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes'),
                onSaved: (value) => notes = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Calories Burned'),
                keyboardType: TextInputType.number,
                onSaved: (value) => caloriesBurned = int.tryParse(value!) ?? 0,
              ),
              ListTile(
                title: Text('Start Time: ${startTime != null ? dateFormat.format(startTime!) : 'Select'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => selectDateTime(context, true),
              ),
              ListTile(
                title: Text('End Time: ${endTime != null ? dateFormat.format(endTime!) : 'Select'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => selectDateTime(context, false),
              ),
              const SizedBox(height: 20),
              ...exercises.asMap().entries.map((entry) {
                final index = entry.key;
                return ExerciseForm(
                  entry: entry.value,
                  onRemove: () => removeExercise(index),
                );
              }),
              TextButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Exercise'),
                onPressed: addExercise,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitWorkout,
                child: Text('Create Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutExerciseEntry {
  String name = '';
  int sets = 3;
  int reps = 10;
  double? weight;
  int rest = 60;

  Map<String, dynamic> toMap() => {
        "name": name,
        "sets": sets,
        "reps": reps,
        "weight": weight,
        "rest_time": rest,
      };
}

class ExerciseForm extends StatelessWidget {
  final WorkoutExerciseEntry entry;
  final VoidCallback onRemove;

  const ExerciseForm({super.key, required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Exercise Name'),
              onSaved: (value) => entry.name = value ?? '',
              validator: (value) => value!.isEmpty ? 'Enter exercise name' : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Sets'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => entry.sets = int.tryParse(value!) ?? 3,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Reps'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => entry.reps = int.tryParse(value!) ?? 10,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => entry.weight = double.tryParse(value!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Rest Time (s)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => entry.rest = int.tryParse(value!) ?? 60,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            )
          ],
        ),
      ),
    );
  }
}


