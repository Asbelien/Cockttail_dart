import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cocktail.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cocktails.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cocktails(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            apiId TEXT,
            name TEXT NOT NULL,
            category TEXT,
            glass TEXT,
            instructions TEXT,
            imageUrl TEXT,
            ingredients TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE cocktails ADD COLUMN ingredients TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  // ==================== COCKTAILS ====================

  Future<int> insertCocktail(Cocktail cocktail) async {
    final db = await database;
    return await db.insert(
      'cocktails',
      cocktail.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Cocktail>> getAllCocktails() async {
    final db = await database;
    final maps = await db.query('cocktails', orderBy: 'name ASC');
    return maps.map((map) => Cocktail.fromMap(map)).toList();
  }

  Future<Cocktail?> getCocktailById(String id) async {
    final db = await database;
    final maps = await db.query(
      'cocktails',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Cocktail.fromMap(maps.first);
  }

  Future<int> updateCocktail(Cocktail cocktail) async {
    final db = await database;
    return await db.update(
      'cocktails',
      cocktail.toMap(),
      where: 'id = ?',
      whereArgs: [cocktail.id],
    );
  }

  Future<int> deleteCocktail(String id) async {
    final db = await database;
    return await db.delete(
      'cocktails',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> hasData() async {
    final db = await database;
    final result = await db.query('cocktails', limit: 1);
    return result.isNotEmpty;
  }

  // ==================== USERS ====================

  Future<bool> registerUser(String username, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'username': username.trim().toLowerCase(),
        'password': _hashPassword(password),
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false; // username duplicado
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [
        username.trim().toLowerCase(),
        _hashPassword(password),
      ],
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<bool> userExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username.trim().toLowerCase()],
    );
    return result.isNotEmpty;
  }

  // Hash simple para no guardar contraseña en texto plano
  String _hashPassword(String password) {
    int hash = 0;
    for (int i = 0; i < password.length; i++) {
      hash = ((hash << 5) - hash + password.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash.abs().toRadixString(16);
  }
}