import 'package:flutter/material.dart';
import '../models/mood.dart';

class MoodCustomizeScreen extends StatefulWidget {
  const MoodCustomizeScreen({super.key});

  @override
  State<MoodCustomizeScreen> createState() => _MoodCustomizeScreenState();
}

class _MoodCustomizeScreenState extends State<MoodCustomizeScreen> {
  late List<MoodCustomizationItem> _moods;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  void _loadMoods() {
    _moods = [
      MoodCustomizationItem(name: 'Zayif', isEnabled: true, color: Colors.red),
      MoodCustomizationItem(name: 'Stresli', isEnabled: true, color: Colors.red),
      MoodCustomizationItem(name: 'Hasta', isEnabled: true, color: Colors.green),
      MoodCustomizationItem(name: 'Notr', isEnabled: true, color: Colors.red),
      MoodCustomizationItem(name: 'Sakin', isEnabled: true, color: Colors.green),
      MoodCustomizationItem(name: 'İyi', isEnabled: true, color: Colors.green),
      MoodCustomizationItem(name: 'Heyecanlı', isEnabled: true, color: Colors.red),
      MoodCustomizationItem(name: 'Harika', isEnabled: true, color: Colors.green),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruh hallerini özelleştir'),
        actions: [
          TextButton(
            onPressed: _hasChanges ? _saveMoods : null,
            child: const Text('Kaydet', style: TextStyle(color: Color(0xFF2196F3))),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Takip için ruh hallerini etkinleştirin veya devre dışı bırakın. Her ruh halinin rengini özelleştirmek için renkli daireye, düzenlemek için ruh hali adına dokunun.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                final mood = _moods[index];
                return ListTile(
                  leading: GestureDetector(
                    onTap: () => _pickColor(index),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mood.color,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                    ),
                  ),
                  title: Text(mood.name),
                  trailing: Switch(
                    value: mood.isEnabled,
                    onChanged: (value) {
                      setState(() {
                        mood.isEnabled = value;
                        _hasChanges = true;
                      });
                    },
                    activeColor: const Color(0xFF2196F3),
                  ),
                  onTap: () => _editMoodName(index),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetToDefault,
                    child: const Text('Geri Yükle'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickColor(int index) async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renk Seç'),
        content: SizedBox(
          width: 200,
          height: 200,
          child: ColorPicker(initialColor: _moods[index].color),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(context, _moods[index].color),
            child: const Text('Seç'),
          ),
        ],
      ),
    );
    if (color != null) {
      setState(() {
        _moods[index].color = color;
        _hasChanges = true;
      });
    }
  }

  void _editMoodName(int index) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ruh Hali Adı'),
        content: TextField(
          controller: TextEditingController(text: _moods[index].name),
          decoration: const InputDecoration(labelText: 'Yeni ad'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(context, (context as dynamic).text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _moods[index].name = newName;
        _hasChanges = true;
      });
    }
  }

  void _saveMoods() {
    // Save to SharedPreferences or database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ruh halleri kaydedildi')),
    );
    setState(() => _hasChanges = false);
  }

  void _resetToDefault() {
    setState(() {
      _loadMoods();
      _hasChanges = true;
    });
  }
}

class MoodCustomizationItem {
  String name;
  bool isEnabled;
  Color color;

  MoodCustomizationItem({
    required this.name,
    required this.isEnabled,
    required this.color,
  });
}

class ColorPicker extends StatefulWidget {
  final Color initialColor;
  const ColorPicker({super.key, required this.initialColor});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _selectedColor;

  final List<Color> _colors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _colors.length,
      itemBuilder: (context, index) {
        final color = _colors[index];
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
            ),
            child: isSelected
                ? const Center(child: Icon(Icons.check, color: Colors.white))
                : null,
          ),
        );
      },
    );
  }
}