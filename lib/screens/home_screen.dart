import 'package:flutter/material.dart';
import '../db/habit_database.dart';
import '../models/habit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Habit> _habits = [];
  final TextEditingController _habitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await HabitDatabase.instance.readAllHabits();
    setState(() {
      _habits.addAll(habits);
    });
  }

  Future<void> _addHabit() async {
    final String habitName = _habitController.text;

    if (habitName.isNotEmpty) {
      final newHabit = Habit(name: habitName, completed: false);
      final habit = await HabitDatabase.instance.create(newHabit);
      setState(() {
        _habits.add(habit);
      });
      _habitController.clear();
    }
  }

  Future<void> _toggleHabitStatus(Habit habit) async {
    final updateHabit = habit.copy(completed: !habit.completed);
    await HabitDatabase.instance.update(updateHabit);

    setState(() {
      final index = _habits.indexWhere((h) => h.id == habit.id);
      _habits[index] = updateHabit;
    });
  }

  Future<void> _deleteHabit(int id) async {
    await HabitDatabase.instance.delete(id);

    setState(() {
      _habits.removeWhere((habit) => habit.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Habit Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _habitController,
              decoration: const InputDecoration(
                labelText: 'Add a new habit',
              ),
              onSubmitted: (_) => _addHabit(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addHabit,
              child: const Text('Add habit'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _habits.isEmpty
                  ? const Center(child: Text('No habits added yet.'))
                  : ListView.builder(
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
                        return ListTile(
                          title: Text(habit.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                value: habit.completed,
                                onChanged: (value) {
                                  _toggleHabitStatus(habit);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteHabit(habit.id!);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
