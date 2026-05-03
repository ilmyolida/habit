import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/category.dart';
import '../utils/database_helper.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Category> _habitCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    _habitCategories = (await DatabaseHelper.instance.getCategories('habit')).cast<Category>();
    _expenseCategories = (await DatabaseHelper.instance.getCategories('expense')).cast<Category>();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategoriler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Alışkanlıklar'),
            Tab(text: 'Harcamalar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(_habitCategories, 'habit'),
                _buildCategoryList(_expenseCategories, 'expense'),
              ],
            ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz kategori eklenmemiş',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddCategoryDialog(type: type),
              child: const Text('Kategori Ekle'),
            ),
          ],
        ),
      );
    }

    return ReorderableListView(
      onReorder: (oldIndex, newIndex) => _reorderCategories(categories, oldIndex, newIndex),
      children: [
        for (int i = 0; i < categories.length; i++)
          Container(
            key: Key('${categories[i].id}_$i'),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  // ignore: deprecated_member_use
                  color: Color(categories[i].color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconFromString(categories[i].icon),
                  color: Color(categories[i].color),
                ),
              ),
              title: Text(categories[i].name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () => _editCategory(categories[i]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteCategory(categories[i].id!),
                  ),
                  const Icon(Icons.drag_handle, color: Colors.grey),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showAddCategoryDialog({String type = 'habit'}) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    String selectedIcon = 'star';

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
                    'Yeni Kategori',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Adı',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Renk', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colors.length,
                      itemBuilder: (context, index) {
                        final color = _colors[index];
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: selectedColor == color
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                            child: selectedColor == color
                                ? const Center(child: Icon(Icons.check, color: Colors.white, size: 20))
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('İkon', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _icons.length,
                      itemBuilder: (context, index) {
                        final icon = _icons[index];
                        final isSelected = selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setState(() {
                            selectedIcon = icon;
                          }),
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: selectedColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: selectedColor, width: 2)
                                  : null,
                            ),
                            child: Icon(
                              _getIconFromString(icon),
                              color: isSelected ? selectedColor : Colors.grey,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
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
                          onPressed: () async {
                            if (nameController.text.isNotEmpty) {
                              final newCategory = Category(
                                name: nameController.text,
                                icon: selectedIcon,
                                // ignore: deprecated_member_use
                                color: selectedColor.value,
                                type: type,
                              );
                              await DatabaseHelper.instance.insertCategory(newCategory);
                              await _loadCategories();
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kategori eklendi')),
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

  void _editCategory(Category category) {
    // Similar to add dialog but with pre-filled values
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Düzenleme yakında gelecek')),
    );
  }

  Future<void> _deleteCategory(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategori Sil'),
        content: const Text('Bu kategoriyi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteCategory(id);
              await _loadCategories();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kategori silindi')),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _reorderCategories(List<Category> categories, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = categories.removeAt(oldIndex);
      categories.insert(newIndex, item);
    });
    // Save order to database
    _loadCategories(); // Reload to persist
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      case 'school': return Icons.school;
      case 'restaurant': return Icons.restaurant;
      case 'favorite': return Icons.favorite;
      case 'movie': return Icons.movie;
      case 'directions_car': return Icons.directions_car;
      case 'star': return Icons.star;
      case 'check_circle': return Icons.check_circle;
      case 'mood': return Icons.mood;
      default: return Icons.category;
    }
  }

  final List<Color> _colors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey,
  ];

  final List<String> _icons = [
    'home', 'work', 'school', 'restaurant', 'favorite', 'movie', 
    'directions_car', 'star', 'check_circle', 'mood', 'category'
  ];
}