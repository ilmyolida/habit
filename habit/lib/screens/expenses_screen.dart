import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/expense_bar_chart.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  bool _showIncome = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<ExpenseBloc>().add(LoadExpenses());
    context.read<ExpenseBloc>().add(LoadExpenseCategories());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcamalar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Harcamalar'),
            Tab(text: 'İstatistikler'),
            Tab(text: 'Kategoriler'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExpenseLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildExpensesList(state, context),
                _buildStatisticsTab(state, context),
                _buildCategoriesTab(context),
              ],
            );
          }
          return const Center(child: Text('Veri bulunamadı'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(),
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildExpensesList(ExpenseLoaded state, BuildContext context) {
    // Filter expenses
    var filteredExpenses = state.expenses;
    if (_selectedCategory != null) {
      filteredExpenses = filteredExpenses.where((e) => e.category == _selectedCategory).toList();
    }
    
    // Group by date
    final Map<DateTime, List<Expense>> groupedExpenses = {};
    for (var expense in filteredExpenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    final sortedDates = groupedExpenses.keys.toList()..sort((a, b) => b.compareTo(a));

    if (filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz harcama eklenmemiş',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddExpenseDialog(),
              child: const Text('Harcama Ekle'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayExpenses = groupedExpenses[date]!;
        final dayTotal = dayExpenses.fold(0.0, (sum, e) => sum + (e.isIncome ? e.amount : -e.amount));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMMM yyyy, EEEE', 'tr').format(date),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '₺${dayTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: dayTotal >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            ...dayExpenses.map((expense) => _buildExpenseTile(expense, context)),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildExpenseTile(Expense expense, BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          _getCategoryIcon(expense.category),
          color: _getCategoryColor(expense.category),
        ),
      ),
      title: Text(expense.category),
      subtitle: expense.note != null ? Text(expense.note!, style: const TextStyle(fontSize: 12)) : null,
      trailing: Text(
        '${expense.isIncome ? '+' : '-'}${expense.amount.toStringAsFixed(2)} ₺',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: expense.isIncome ? Colors.green : Colors.red,
        ),
      ),
      onTap: () => _showExpenseDetails(expense, context),
    );
  }

  Widget _buildStatisticsTab(ExpenseLoaded state, BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        if (settingsState is SettingsLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Toplam Gider',
                        state.totalExpense,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Toplam Gelir',
                        state.totalIncome,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Bakiye',
                        state.balance,
                        state.balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Pie Chart
                const Text(
                  'Kategori Dağılımı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: context.read<ExpenseBloc>().stream.first,
                    builder: (context, snapshot) {
                      return ExpensePieChart(
                        expenses: state.expenses,
                        categories: [],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Bar Chart
                const Text(
                  'Günlük Harcamalar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ExpenseBarChart(expenses: state.expenses),
                ),
                const SizedBox(height: 24),
                
                // Total by category
                const Text(
                  'Kategori Bazında Toplam',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._getCategoryTotals(state.expenses).entries.map((entry) {
                  return _buildCategoryTotalTile(entry.key, entry.value);
                }),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            '₺${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTotalTile(String category, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: _getCategoryColor(category),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(category)),
          Text(
            '₺${total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseCategoriesLoaded) {
          return ListView.builder(
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(category.color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconFromString(category.icon),
                    color: Color(category.color),
                  ),
                ),
                title: Text(category.name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () => _editCategory(category),
                ),
                onLongPress: () => _deleteCategory(category.id!),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showAddExpenseDialog() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedCategory = 'Gida';
    bool isIncome = false;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yeni İşlem',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount field
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tutar',
                      prefixText: '₺ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: ['Gida', 'Konut', 'Egitim', 'Saglik', 'Eglence', 'Araba', 'Diger']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v!),
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Note field
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Not (isteğe bağlı)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Date picker
                  ListTile(
                    title: const Text('Tarih'),
                    subtitle: Text(DateFormat('dd MMMM yyyy', 'tr').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Income/Expense switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gelir'),
                      Switch(
                        value: isIncome,
                        onChanged: (v) => setState(() => isIncome = v),
                        activeTrackColor: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final amount = double.tryParse(amountController.text);
                            if (amount != null && amount > 0) {
                              final expense = Expense(
                                amount: amount,
                                category: selectedCategory,
                                date: selectedDate,
                                note: noteController.text.isNotEmpty ? noteController.text : null,
                                isIncome: isIncome,
                              );
                              context.read<ExpenseBloc>().add(AddExpense(expense));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${isIncome ? "Gelir" : "Harcama"} eklendi')),
                              );
                            }
                          },
                          child: const Text('Ekle'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showExpenseDetails(Expense expense, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.category),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tutar: ₺${expense.amount.toStringAsFixed(2)}'),
            Text('Tarih: ${DateFormat('dd MMMM yyyy', 'tr').format(expense.date)}'),
            if (expense.note != null) Text('Not: ${expense.note}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExpenseBloc>().add(DeleteExpense(expense.id!));
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editCategory(Category category) {
    // TODO: Implement category editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kategori düzenleme yakında gelecek')),
    );
  }

  void _deleteCategory(int id) {
    // TODO: Implement category deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kategori silme yakında gelecek')),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Harcama Ara'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Kategori veya not ara...'),
          onChanged: (value) {
            // TODO: Implement search
          },
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kategori Seç'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Tümü'),
              items: ['Gida', 'Konut', 'Egitim', 'Saglik', 'Eglence', 'Araba', 'Diger']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedCategory = v);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Gida': return const Color(0xFFFF9800);
      case 'Konut': return const Color(0xFF4CAF50);
      case 'Egitim': return const Color(0xFF2196F3);
      case 'Saglik': return const Color(0xFFE91E63);
      case 'Eglence': return const Color(0xFF9C27B0);
      case 'Araba': return const Color(0xFF607D8B);
      default: return const Color(0xFF9E9E9E);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Gida': return Icons.restaurant;
      case 'Konut': return Icons.home;
      case 'Egitim': return Icons.school;
      case 'Saglik': return Icons.favorite;
      case 'Eglence': return Icons.movie;
      case 'Araba': return Icons.directions_car;
      default: return Icons.more_horiz;
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'home': return Icons.home;
      case 'school': return Icons.school;
      case 'restaurant': return Icons.restaurant;
      case 'favorite': return Icons.favorite;
      case 'movie': return Icons.movie;
      case 'directions_car': return Icons.directions_car;
      default: return Icons.more_horiz;
    }
  }

  Map<String, double> _getCategoryTotals(List<Expense> expenses) {
    final Map<String, double> totals = {};
    for (var expense in expenses.where((e) => !e.isIncome)) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }
}