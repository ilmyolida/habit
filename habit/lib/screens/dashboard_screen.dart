import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/habit_bloc.dart';
import '../widgets/weekly_calendar.dart';
import '../widgets/category_chips.dart';
import '../widgets/habit_card.dart';
import '../widgets/premium_banner.dart';
import 'mood_tracker_screen.dart';
import 'expenses_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const DashboardContent(),
      const HabitsListScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptionsDialog,
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.today, 'Bugun', 0),
            _buildNavItem(Icons.repeat, 'Alışkanlıklar', 1),
            _buildNavItem(Icons.show_chart, 'İstatistikler', 2),
            _buildNavItem(Icons.person, 'Profil', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? const Color(0xFF2196F3) : Colors.grey),
      onPressed: () => setState(() => _selectedIndex = index),
    );
  }

  void _showAddOptionsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mood, color: Color(0xFF2196F3)),
              title: const Text('Duygu Ekle'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodTrackerScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Color(0xFF4CAF50)),
              title: const Text('Harcama Ekle'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFFFF9800)),
              title: const Text('Alışkanlık Ekle'),
              onTap: () {
                Navigator.pop(context);
                _showAddHabitDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Alışkanlık'),
        content: const TextField(
          decoration: InputDecoration(labelText: 'Alışkanlık Adı'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Ekle')),
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const WeeklyCalendar(),
          const CategoryChips(),
          Expanded(
            child: BlocBuilder<HabitBloc, HabitState>(
              builder: (context, state) {
                if (state is HabitLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is HabitLoaded) {
                  if (state.todayTasks.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aktivite bulunamadı',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.todayTasks.length,
                    itemBuilder: (context, index) {
                      final habit = state.todayTasks[index];
                      final isCompleted = habit.completedDays.contains(
                        DateTime.now().millisecondsSinceEpoch,
                      );
                      return HabitCard(
                        habit: habit,
                        isCompleted: isCompleted,
                        onToggle: () {
                          context.read<HabitBloc>().add(
                            ToggleHabitComplete(habit, DateTime.now()),
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HabitsListScreen extends StatelessWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alışkanlıklar')),
      body: const Center(child: Text('Alışkanlık listesi yakında gelecek')),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: const Center(
        child: Text('Premium özelliklerle deneyiminizi geliştirin. Şimdi açın!'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          const PremiumBanner(onTap: null),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }
}