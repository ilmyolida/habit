import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unused_import
import '../bloc/settings_bloc.dart';
import '../models/quick_action.dart';
import '../utils/database_helper.dart';

class QuickActionsScreen extends StatefulWidget {
  const QuickActionsScreen({super.key});

  @override
  State<QuickActionsScreen> createState() => _QuickActionsScreenState();
}

class _QuickActionsScreenState extends State<QuickActionsScreen> {
  List<QuickAction> _actions = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    final actions = await DatabaseHelper.instance.getQuickActions();
    setState(() => _actions = actions);
  }

  Future<void> _saveActions() async {
    for (var action in _actions) {
      await DatabaseHelper.instance.updateQuickAction(action);
    }
    setState(() => _hasChanges = false);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hızlı işlemler kaydedildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hızlı İşlemleri Özelleştir'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveActions,
              child: const Text('Kaydet', style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Hızlı menüde tutmak istediğiniz işlemleri seçin. Açıp/kapatın ve sıralamayı ayarlamak için sürükleyin. İlk aktif işlem varsayılan olarak açılacaktır.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _actions.removeAt(oldIndex);
                  _actions.insert(newIndex, item);
                  for (int i = 0; i < _actions.length; i++) {
                    _actions[i].order = i;
                  }
                  _hasChanges = true;
                });
              },
              children: [
                for (int i = 0; i < _actions.length; i++)
                  _buildActionTile(_actions[i], i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(QuickAction action, int index) {
    return Container(
      key: Key('${action.id}_$index'),
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
            color: action.isEnabled ? const Color(0xFF2196F3).withValues(alpha: 0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconForAction(action.id),
            color: action.isEnabled ? const Color(0xFF2196F3) : Colors.grey[400],
          ),
        ),
        title: Text(
          action.name,
          style: TextStyle(
            color: action.isEnabled ? Colors.black87 : Colors.grey[500],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: action.isEnabled,
              onChanged: (value) {
                setState(() {
                  action.isEnabled = value;
                  _hasChanges = true;
                });
              },
              activeTrackColor: const Color(0xFF2196F3),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAction(String id) {
    switch (id) {
      case 'habits': return Icons.check_circle;
      case 'moods': return Icons.mood;
      case 'expenses': return Icons.attach_money;
      case 'journal': return Icons.edit_note;
      case 'focus': return Icons.timer;
      default: return Icons.star;
    }
  }
}