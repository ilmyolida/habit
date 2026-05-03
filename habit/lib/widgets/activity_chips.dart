import 'package:flutter/material.dart';
import '../models/category.dart';

class ActivityChips extends StatefulWidget {
  final Function(List<String>)? onActivitiesChanged;
  final List<String>? initialSelected;
  
  const ActivityChips({super.key, this.onActivitiesChanged, this.initialSelected});

  @override
  State<ActivityChips> createState() => _ActivityChipsState();
}

class _ActivityChipsState extends State<ActivityChips> {
  late Set<String> _selectedActivities;
  
  @override
  void initState() {
    super.initState();
    _selectedActivities = Set.from(widget.initialSelected ?? []);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Neler oluyor?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: defaultMoodActivities.map((activity) {
            final isSelected = _selectedActivities.contains(activity);
            return FilterChip(
              label: Text(activity),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedActivities.add(activity);
                  } else {
                    _selectedActivities.remove(activity);
                  }
                });
                widget.onActivitiesChanged?.call(_selectedActivities.toList());
              },
              backgroundColor: Colors.grey[100],
              selectedColor: const Color(0xFF2196F3).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF2196F3),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}