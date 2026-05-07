import 'package:habit/models/category.dart';
// ignore: duplicate_import
import 'package:habit/models/category.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/mood.dart';
import '../models/mood_tag.dart';
import '../models/expense.dart';
import '../models/category.dart' as category_model;
import '../models/user_settings.dart';
import '../models/quick_action.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habitgenius.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Habits table
    await db.execute('''
      CREATE TABLE habits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon TEXT NOT NULL,
        isActive INTEGER NOT NULL,
        isArchived INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        completedDays TEXT NOT NULL,
        frequency TEXT NOT NULL,
        targetCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');

    // Mood entries table
    await db.execute('''
      CREATE TABLE mood_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        mood INTEGER NOT NULL,
        activities TEXT NOT NULL,
        tags TEXT NOT NULL,
        note TEXT
      )
    ''');

    // Mood tags table
    await db.execute('''
      CREATE TABLE mood_tags(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        isIncome INTEGER NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY,
        darkMode INTEGER NOT NULL,
        themeColor INTEGER NOT NULL,
        passwordLock INTEGER NOT NULL,
        language TEXT NOT NULL,
        firstDayOfWeek INTEGER NOT NULL,
        use24HourFormat INTEGER NOT NULL,
        vibrateOnTap INTEGER NOT NULL,
        completionSound INTEGER NOT NULL,
        goalAchievedSound INTEGER NOT NULL,
        alarmTone TEXT NOT NULL,
        hideCompletedActivities INTEGER NOT NULL,
        customCategories TEXT NOT NULL,
        habitOrder TEXT NOT NULL,
        defaultScreen TEXT NOT NULL,
        currencySymbol TEXT NOT NULL,
        usdToUzs REAL NOT NULL,
        autoBackup INTEGER NOT NULL,
        notificationsEnabled INTEGER NOT NULL,
        reminderTime TEXT NOT NULL
      )
    ''');

    // Quick actions table
    await db.execute('''
      CREATE TABLE quick_actions(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        isEnabled INTEGER NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insert default mood tags
    for (var tag in defaultMoodTags) {
      await db.insert('mood_tags', tag.toMap());
    }

    // Insert default categories
    for (var cat in category_model.defaultHabitCategories) {
      await db.insert('categories', cat.toMap());
    }
    for (var cat in defaultExpenseCategories) {
      await db.insert('categories', cat.toMap());
    }

    // Insert default settings
    final defaultSettings = UserSettings(
      darkMode: false,
      themeColor: 0xFF2196F3,
      passwordLock: false,
      language: 'tr',
      firstDayOfWeek: 0,
      use24HourFormat: false,
      vibrateOnTap: true,
      completionSound: true,
      goalAchievedSound: true,
      alarmTone: 'Sabah kuşu',
      hideCompletedActivities: false,
      customCategories: [],
      habitOrder: [],
      defaultScreen: 'Bugün',
      currencySymbol: 'so\'m',
      usdToUzs: 12800.0,
      autoBackup: false,
      notificationsEnabled: true,
      reminderTime: '09:00',
    );
    await db.insert('settings', defaultSettings.toMap());

    // Insert default quick actions
    for (var action in defaultQuickActions) {
      await db.insert('quick_actions', action.toMap());
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      // Migration for lost data recovery (Kayıp verileri kurtar)
      try {
        await db.execute('ALTER TABLE mood_entries ADD COLUMN tags TEXT');
      } catch (e) {
        // Column might already exist
      }

      try {
        await db.execute('ALTER TABLE settings ADD COLUMN currencySymbol TEXT');
        await db.execute('ALTER TABLE settings ADD COLUMN usdToUzs REAL');
        await db.execute('ALTER TABLE settings ADD COLUMN autoBackup INTEGER');
        await db.execute(
          'ALTER TABLE settings ADD COLUMN notificationsEnabled INTEGER',
        );
        await db.execute('ALTER TABLE settings ADD COLUMN reminderTime TEXT');
      } catch (e) {
        // Migration already applied
      }
    }
  }

  // Habit operations
  Future<List<Habit>> getHabits({bool? isActive}) async {
    final db = await database;
    final String where = isActive != null
        ? 'isActive = ${isActive ? 1 : 0}'
        : '1=1';
    final result = await db.query('habits', where: where);
    return result.map((e) => Habit.fromMap(e)).toList();
  }

  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // Mood operations
  Future<List<MoodEntry>> getMoodEntries({DateTime? from, DateTime? to}) async {
    final db = await database;
    String where = '1=1';
    if (from != null) where += ' AND date >= "${from.toIso8601String()}"';
    if (to != null) where += ' AND date <= "${to.toIso8601String()}"';
    final result = await db.query('mood_entries', where: where);
    return result.map((e) => MoodEntry.fromMap(e)).toList();
  }

  Future<MoodEntry?> getMoodEntryByDate(DateTime date) async {
    final db = await database;
    final result = await db.query(
      'mood_entries',
      where: 'date = ?',
      whereArgs: [date.toIso8601String()],
    );
    if (result.isEmpty) return null;
    return MoodEntry.fromMap(result.first);
  }

  Future<int> insertMoodEntry(MoodEntry entry) async {
    final db = await database;
    return await db.insert(
      'mood_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateMoodEntry(MoodEntry entry) async {
    final db = await database;
    return await db.update(
      'mood_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // Mood tags operations
  Future<List<MoodTag>> getMoodTags() async {
    final db = await database;
    final result = await db.query('mood_tags', orderBy: 'sort_order ASC');
    return result.map((e) => MoodTag.fromMap(e)).toList();
  }

  Future<int> updateMoodTag(MoodTag tag) async {
    final db = await database;
    return await db.update(
      'mood_tags',
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<int> insertMoodTag(MoodTag tag) async {
    final db = await database;
    return await db.insert('mood_tags', tag.toMap());
  }

  Future<int> deleteMoodTag(int id) async {
    final db = await database;
    return await db.delete('mood_tags', where: 'id = ?', whereArgs: [id]);
  }

  // Expense operations
  Future<List<Expense>> getExpenses({DateTime? from, DateTime? to}) async {
    final db = await database;
    String where = '1=1';
    if (from != null) where += ' AND date >= "${from.toIso8601String()}"';
    if (to != null) where += ' AND date <= "${to.toIso8601String()}"';
    final result = await db.query(
      'expenses',
      where: where,
      orderBy: 'date DESC',
    );
    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Categories operations
  Future<List<category_model.Category>> getCategories(String type) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
    return result.map((e) => category_model.Category.fromMap(e)).toList();
  }

  Future<int> insertCategory(category_model.Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Settings operations
  Future<UserSettings> getSettings() async {
    final db = await database;
    final result = await db.query('settings', where: 'id = 1');
    if (result.isEmpty) {
      final defaultSettings = UserSettings(
        darkMode: false,
        themeColor: 0xFF2196F3,
        passwordLock: false,
        language: 'tr',
        firstDayOfWeek: 0,
        use24HourFormat: false,
        vibrateOnTap: true,
        completionSound: true,
        goalAchievedSound: true,
        alarmTone: 'Sabah kuşu',
        hideCompletedActivities: false,
        customCategories: [],
        habitOrder: [],
        defaultScreen: 'Bugün',
        currencySymbol: 'so\'m',
        usdToUzs: 12800.0,
        autoBackup: false,
        notificationsEnabled: true,
        reminderTime: '09:00',
      );
      await db.insert('settings', defaultSettings.toMap());
      return defaultSettings;
    }
    return UserSettings.fromMap(result.first);
  }

  Future<int> updateSettings(UserSettings settings) async {
    final db = await database;
    return await db.update('settings', settings.toMap(), where: 'id = 1');
  }

  // Quick actions operations
  Future<List<QuickAction>> getQuickActions() async {
    final db = await database;
    final result = await db.query('quick_actions', orderBy: 'sort_order ASC');
    return result.map((e) => QuickAction.fromMap(e)).toList();
  }

  Future<int> updateQuickAction(QuickAction action) async {
    final db = await database;
    return await db.update(
      'quick_actions',
      action.toMap(),
      where: 'id = ?',
      whereArgs: [action.id],
    );
  }

  Future<void> updateQuickActionsOrder(List<QuickAction> actions) async {
    final db = await database;
    final batch = db.batch();
    for (var action in actions) {
      batch.update(
        'quick_actions',
        action.toMap(),
        where: 'id = ?',
        whereArgs: [action.id],
      );
    }
    await batch.commit();
  }

  // Export/Import for backup
  Future<List<Map<String, dynamic>>> exportAllData() async {
    final db = await database;
    final tables = [
      'habits',
      'mood_entries',
      'mood_tags',
      'expenses',
      'categories',
      'settings',
      'quick_actions',
    ];
    Map<String, dynamic> exportData = {};
    for (var table in tables) {
      exportData[table] = await db.query(table);
    }
    return [exportData];
  }

  Future<void> importData(List<Map<String, dynamic>> data) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var tableData in data) {
        for (var entry in tableData.entries) {
          await txn.insert(entry.key, entry.value as Map<String, dynamic>);
        }
      }
    });
  }
}
