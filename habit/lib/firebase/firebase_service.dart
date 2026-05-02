import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/habit.dart';
import '../models/mood.dart';
import '../models/expense.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Check if user is signed in
  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => currentUser != null;

  // Sign in with Google
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google sign in error: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Sync habits to cloud
  static Future<void> syncHabits(List<Habit> habits) async {
    if (currentUser == null) return;
    
    final userDoc = _firestore.collection('users').doc(currentUser!.uid);
    final batch = _firestore.batch();
    
    for (var habit in habits) {
      final habitRef = userDoc.collection('habits').doc(habit.id.toString());
      batch.set(habitRef, {
        'name': habit.name,
        'category': habit.category,
        'color': habit.color,
        'icon': habit.icon,
        'isActive': habit.isActive,
        'isArchived': habit.isArchived,
        'createdAt': habit.createdAt.toIso8601String(),
        'completedDays': habit.completedDays,
        'frequency': habit.frequency,
        'targetCount': habit.targetCount,
        'currentCount': habit.currentCount,
        'lastSynced': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }

  // Sync moods to cloud
  static Future<void> syncMoods(List<MoodEntry> moods) async {
    if (currentUser == null) return;
    
    final userDoc = _firestore.collection('users').doc(currentUser!.uid);
    final batch = _firestore.batch();
    
    for (var mood in moods) {
      final moodRef = userDoc.collection('moods').doc(mood.id.toString());
      batch.set(moodRef, {
        'date': mood.date.toIso8601String(),
        'mood': mood.mood.value,
        'activities': mood.activities,
        'tags': mood.tags,
        'note': mood.note,
        'lastSynced': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }

  // Sync expenses to cloud
  static Future<void> syncExpenses(List<Expense> expenses) async {
    if (currentUser == null) return;
    
    final userDoc = _firestore.collection('users').doc(currentUser!.uid);
    final batch = _firestore.batch();
    
    for (var expense in expenses) {
      final expenseRef = userDoc.collection('expenses').doc(expense.id.toString());
      batch.set(expenseRef, {
        'amount': expense.amount,
        'category': expense.category,
        'date': expense.date.toIso8601String(),
        'note': expense.note,
        'isIncome': expense.isIncome,
        'lastSynced': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }

  // Load habits from cloud
  static Future<List<Map<String, dynamic>>> loadHabitsFromCloud() async {
    if (currentUser == null) return [];
    
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('habits')
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Load moods from cloud
  static Future<List<Map<String, dynamic>>> loadMoodsFromCloud() async {
    if (currentUser == null) return [];
    
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('moods')
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Load expenses from cloud
  static Future<List<Map<String, dynamic>>> loadExpensesFromCloud() async {
    if (currentUser == null) return [];
    
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('expenses')
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Full backup to cloud
  static Future<void> fullBackup() async {
    if (currentUser == null) return;
    
    final userDoc = _firestore.collection('users').doc(currentUser!.uid);
    
    // Get local data from database
    final db = await DatabaseHelper.instance.database;
    final habits = await db.query('habits');
    final moods = await db.query('mood_entries');
    final expenses = await db.query('expenses');
    final settings = await db.query('settings');
    
    // Save to cloud
    await userDoc.set({
      'habits': habits,
      'moods': moods,
      'expenses': expenses,
      'settings': settings,
      'backupDate': FieldValue.serverTimestamp(),
    });
  }

  // Restore from cloud
  static Future<Map<String, dynamic>?> fullRestore() async {
    if (currentUser == null) return null;
    
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}