import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/habit_bloc.dart';
import '../models/habit.dart';

class HabitOrderScreen extends StatefulWidget {
  const HabitOrderScreen({super.key});

  @override
  State<HabitOrderScreen> createState() => _HabitOrderScreenState();
}

class _HabitOrderScreenState extends State<HabitOrderScreen> {
  List<Habit> _habits = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    final state = context.read<HabitBloc>().state;
    if (state is HabitLoaded) {
      setState(() => _habits = List.from(state.activeHabits));
    }
  }

  void _saveOrder() {
    for (int i = 0; i < _habits.length; i++) {
      context.read<HabitBloc>().add(UpdateHabit(_habits[i]));
    }
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sıralama kaydedildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışkanlıkları Sırala'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveOrder,
              child: const Text('Kaydet', style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          if (state is HabitLoaded && state.activeHabits.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.drag_indicator, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Uzun basın ve sürükleyin',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _habits.removeAt(oldIndex);
                          _habits.insert(newIndex, item);
                          _hasChanges = true;
                        });
                      },
                      children: [
                        for (int i = 0; i < _habits.length; i++)
                          Container(
                            key: Key('${_habits[i].id}_$i'),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(_habits[i].color).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Color(_habits[i].color),
                                ),
                              ),
                              title: Text(_habits[i].name),
                              subtitle: Text(_habits[i].category),
                              trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Aktif alışkanlık bulunamadı'));
        },
      ),
    );
  }
}