import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'database_helper.dart';

class BackupHelper {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  static Future<String> createLocalBackup() async {
    final db = await DatabaseHelper.instance.database;
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '${dir.path}/habitgenius_backup_$timestamp.db';
    
    // Export database to file
    final bytes = await _exportDatabase(db);
    await File(backupPath).writeAsBytes(bytes);
    
    return backupPath;
  }

  static Future<void> restoreFromLocal(String path) async {
    final db = await DatabaseHelper.instance.database;
    final bytes = await File(path).readAsBytes();
    await _importDatabase(db, bytes);
  }

  static Future<bool> signInToGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> syncToGoogleDrive() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Not signed in');
    
    final auth = await account.authentication;
    final client = GoogleAuthClient(auth.accessToken!);
    final driveApi = drive.DriveApi(client);
    
    // Create backup file
    final backupPath = await createLocalBackup();
    final backupFile = File(backupPath);
    
    // Upload to Drive
    final media = drive.Media(backupFile.openRead(), await backupFile.length());
    await driveApi.files.create(
      drive.File(name: 'habitgenius_backup.db'),
      uploadMedia: media,
    );
  }

  static Future<void> restoreFromGoogleDrive() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Not signed in');
    
    final auth = await account.authentication;
    final client = GoogleAuthClient(auth.accessToken!);
    final driveApi = drive.DriveApi(client);
    
    // Find backup file
    final files = await driveApi.files.list(q: "name='habitgenius_backup.db'");
    if (files.files == null || files.files!.isEmpty) {
      throw Exception('No backup found');
    }
    
    final file = files.files!.first;
    final response = await driveApi.files.get(
      file.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );
    
    if (response is drive.DownloadFullMedia) {
      final dir = await getTemporaryDirectory();
      final tempPath = '${dir.path}/temp_restore.db';
      await File(tempPath).writeAsBytes(response.bytes!);
      await restoreFromLocal(tempPath);
    }
  }

  static Future<Uint8List> _exportDatabase(Database db) async {
    // Get all tables data
    final tables = ['habits', 'mood_entries', 'mood_tags', 'expenses', 'categories', 'settings', 'quick_actions'];
    final exportData = <String, dynamic>{};
    
    for (var table in tables) {
      final data = await db.query(table);
      exportData[table] = data;
    }
    
    return Uint8List.fromList(exportData.toString().codeUnits);
  }

  static Future<void> _importDatabase(Database db, Uint8List bytes) async {
    // Parse and import - simplified version
    final importData = String.fromCharCodes(bytes);
    // In production, properly parse JSON and insert
  }

  static Future<String> exportToCSV() async {
    final db = await DatabaseHelper.instance.database;
    final expenses = await db.query('expenses');
    
    String csv = 'ID,Amount,Category,Date,Note,IsIncome\n';
    for (var e in expenses) {
      csv += '${e['id']},${e['amount']},${e['category']},${e['date']},${e['note']},${e['isIncome']}\n';
    }
    
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/expenses_export.csv';
    await File(path).writeAsString(csv);
    
    return path;
  }

  static Future<bool> hasGoogleSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}

class GoogleAuthClient extends http.BaseClient {
  final String _token;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
}