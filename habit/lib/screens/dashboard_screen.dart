import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/settings_bloc.dart';
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
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Diger';

  final List<Widget> _pages = [];
  final List<String> _pageTitles = ['Bugun', 'Alışkanlıklar', 'İstatistikler', 'Profil'];

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
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF2196F3),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Alışkanlık Adı')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['Diger', 'Saglik', 'Calisma', 'Is', 'Ana Sayfa']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
          ],
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
          WeeklyCalendar(),
          CategoryChips(),
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alışkanlıklar ve Görevler'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Arşivlenmiş'),
            ],
          ),
        ),
        body: BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            if (state is HabitLoaded) {
              return TabBarView(
                children: [
                  _buildHabitList(state.activeHabits, context),
                  _buildHabitList(state.archivedHabits, context, showArchive: true),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildHabitList(List<Habit> habits, BuildContext context, {bool showArchive = false}) {
    if (habits.isEmpty) {
      return const Center(child: Text('Alışkanlık bulunamadı'));
    }
    return ListView.builder(
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(habit.color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle, color: Color(habit.color)),
          ),
          title: Text(habit.name),
          subtitle: Text('${habit.currentCount}/${habit.targetCount} tamamlandı'),
          trailing: showArchive
              ? IconButton(
                  icon: const Icon(Icons.unarchive, color: Colors.green),
                  onPressed: () => context.read<HabitBloc>().add(ArchiveHabit(habit.id!, false)),
                )
              : IconButton(
                  icon: const Icon(Icons.archive, color: Colors.grey),
                  onPressed: () => context.read<HabitBloc>().add(ArchiveHabit(habit.id!, true)),
                ),
          onTap: () => _showHabitDetails(context, habit),
        );
      },
    );
  }

  void _showHabitDetails(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(habit.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Kategori: ${habit.category}'),
            Text('Hedef: ${habit.targetCount} gün'),
            Text('Tamamlanan: ${habit.currentCount} gün'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
          TextButton(
            onPressed: () {
              context.read<HabitBloc>().add(DeleteHabit(habit.id!));
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
          const PremiumBanner(
            onTap: null,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Yedekler'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.stars),
            title: const Text('Premium\'a Geç'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.fast_forward),
            title: const Text('Hızlı İşlemler'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickActionsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hakkında'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'HabitGenius v3.2.4',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'HabitGenius',
      applicationVersion: '3.2.4',
      applicationIcon: const Icon(Icons.check_circle, size: 40, color: Color(0xFF2196F3)),
      children: [
        const Text('5 Güçlü Araç Tek Uygulamada: Alışkanlıklar, Duygular, Harcamalar, Günlük, Odaklanma'),
      ],
    );
  }
}