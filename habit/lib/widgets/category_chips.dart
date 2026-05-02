import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final Function(String)? onCategorySelected;
  final String? selectedCategory;
  
  const CategoryChips({super.key, this.onCategorySelected, this.selectedCategory});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  late String _selectedCategory;
  
  final List<String> _categories = ['Diger', 'Saglik', 'Calisma', 'Is', 'Ana Sayfa'];
  
  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory ?? _categories[0];
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = category == _selectedCategory;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  widget.onCategorySelected?.call(category);
                },
                backgroundColor: Colors.grey[100],
                selectedColor: const Color(0xFF2196F3),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
                checkmarkColor: Colors.white,
                side: BorderSide.none,
              ),
            );
          },
        ),
      ),
    );
  }
}