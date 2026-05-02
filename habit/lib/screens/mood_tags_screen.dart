import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/mood_bloc.dart';
import '../models/mood_tag.dart';

class MoodTagsScreen extends StatefulWidget {
  const MoodTagsScreen({super.key});

  @override
  State<MoodTagsScreen> createState() => _MoodTagsScreenState();
}

class _MoodTagsScreenState extends State<MoodTagsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MoodBloc>().add(LoadMoodTags());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duygu Etiketleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTagDialog,
          ),
        ],
      ),
      body: BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          if (state is MoodTagsLoaded) {
            final tags = state.tags.where((t) => t.isActive).toList();
            if (tags.isEmpty) {
              return const Center(child: Text('Henüz etiket eklenmemiş'));
            }
            return ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                context.read<MoodBloc>().add(ReorderMoodTags(oldIndex, newIndex));
              },
              children: [
                for (int i = 0; i < tags.length; i++)
                  ListTile(
                    key: Key('${tags[i].id}'),
                    leading: const Icon(Icons.drag_handle, color: Colors.grey),
                    title: Text(tags[i].name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteTag(tags[i].id!),
                    ),
                    onTap: () => _editTag(tags[i]),
                  ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ruh hali etiketi ekle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Etiket Adı',
            hintText: 'Etiket adı girin',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<MoodBloc>().add(AddMoodTag(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _editTag(MoodTag tag) {
    final controller = TextEditingController(text: tag.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etiketi Düzenle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Etiket Adı'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<MoodBloc>().add(UpdateMoodTag(tag.copyWith(name: controller.text)));
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _deleteTag(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etiketi Sil'),
        content: const Text('Bu etiketi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              context.read<MoodBloc>().add(DeleteMoodTag(id));
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}