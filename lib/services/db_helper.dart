import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'manga_reviews.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reviews(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mangaId TEXT,
          mangaTitle TEXT,
          userId TEXT,
          rating INTEGER,
          comment TEXT,
          imagePath TEXT
        )
        ''');
      },
    );
  }
}