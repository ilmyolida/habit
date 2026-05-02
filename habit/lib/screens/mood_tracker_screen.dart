import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/mood_bloc.dart';
import '../models/mood.dart';
import '../widgets/mood_selector.dart';
import '../widgets/activity_chips.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  MoodLevel? _selectedMood;
  List<String> _selectedActivities = [];
  List<String> _selectedTags = [];
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<MoodBloc>().add(LoadMoodByDate(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd MMMM yyyy, EEEE', 'tr').format(_selectedDate)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveMood,
          ),
        ],
      ),
      body: BlocListener<MoodBloc, MoodState>(
        listener: (context, state) {
          if (state is MoodLoaded && state.todayMood != null) {
            setState(() {
              _selectedMood = state.todayMood!.mood;
              _selectedActivities = state.todayMood!.activities;
              _selectedTags = state.todayMood!.tags;
              _noteController.text = state.todayMood!.note ?? '';
            });
          }
          if (state is MoodSaved) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ruh haliniz kaydedildi')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MoodSelector(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) => setState(() => _selectedMood = mood),
              ),
              const SizedBox(height: 24),
              ActivityChips(
                initialSelected: _selectedActivities,
                onActivitiesChanged: (activities) => setState(() => _selectedActivities = activities),
              ),
              const SizedBox(height: 24),
              const Text(
                'Not ekle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ruh halinizle ilgili düşüncelerinizi veya detayları yazın...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Ruh halinizi tanımlayın',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToTags(),
                      icon: const Icon(Icons.label),
                      label: const Text('Etiketler'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showMoodCustomize(),
                      icon: const Icon(Icons.settings),
                      label: const Text('Özelleştir'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMood() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir ruh hali seçin')),
      );
      return;
    }

    final moodEntry = MoodEntry(
      date: _selectedDate,
      mood: _selectedMood!,
      activities: _selectedActivities,
      tags: _selectedTags,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );
    context.read<MoodBloc>().add(SaveMood(moodEntry));
  }

  void _navigateToTags() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodTagsScreen())).then((_) {
      context.read<MoodBloc>().add(LoadMoodTags());
    });
  }

  void _showMoodCustomize() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodCustomizeScreen()));
  }
}