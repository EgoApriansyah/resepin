import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/recipe_model.dart';
import '../../data/models/ingredient_model.dart';
import 'dart:convert';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'recipe_db.db');
    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabel User (Update: fullName diganti email)
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT UNIQUE,
        password TEXT,
        photoPath TEXT
      )
    ''');

    // 2. Tabel Recipes
    await db.execute('''
      CREATE TABLE recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        category TEXT,
        steps TEXT,
        ingredients TEXT,
        imagePath TEXT,
        isFavorite INTEGER
      )
    ''');
  }

  // ==========================================
  // --- OPERATIONS UNTUK USER (AUTHENTICATION) ---
  // ==========================================

  // Register User
  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  // Login User menggunakan EMAIL dan PASSWORD
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Update Foto Profil
  Future<int> updateUserPhoto(int userId, String path) async {
    final db = await database;
    return await db.update(
      'users',
      {'photoPath': path},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Ambil data user spesifik
  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users', 
      where: 'id = ?', 
      whereArgs: [id]
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ==========================================
  // --- OPERATIONS UNTUK RECIPE (CRUD) ---
  // ==========================================

  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    final recipeMap = recipe.toMap();
    
    recipeMap['steps'] = jsonEncode(recipe.steps);
    recipeMap['ingredients'] = jsonEncode(recipe.ingredients.map((i) => i.toMap()).toList());
    
    return await db.insert('recipes', recipeMap);
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    
    return List.generate(maps.length, (i) {
      final map = maps[i];
      
      final stepsList = (jsonDecode(map['steps']) as List<dynamic>).cast<String>();
      
      final ingredientsList = (jsonDecode(map['ingredients']) as List<dynamic>)
          .map((ingredientMap) => Ingredient.fromMap(ingredientMap))
          .toList();

      return Recipe(
        id: map['id']?.toInt(),
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        category: map['category'] ?? '',
        steps: stepsList,
        ingredients: ingredientsList,
        imagePath: map['imagePath'] ?? 'assets/images/placeholder.png',
        isFavorite: map['isFavorite'] == 1,
      );
    });
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database;
    final recipeMap = recipe.toMap();

    recipeMap['steps'] = jsonEncode(recipe.steps);
    recipeMap['ingredients'] = jsonEncode(recipe.ingredients.map((i) => i.toMap()).toList());

    return await db.update(
      'recipes', 
      recipeMap, 
      where: 'id = ?', 
      whereArgs: [recipe.id]
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDb() async {
    final db = await database;
    db.close();
  }
}