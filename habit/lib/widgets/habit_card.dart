import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;
  
  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(habit.color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getIconData(habit.icon),
                    color: Color(habit.color),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[400],
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'work':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'restaurant':
        return Icons.restaurant;
      case 'movie':
        return Icons.movie;
      case 'directions_car':
        return Icons.directions_car;
      default:
        return Icons.check_circle;
    }
  }
}