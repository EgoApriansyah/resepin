// lib/core/database/db_helper.dart
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

  // Getter untuk database, akan membuat database jika belum ada
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Inisialisasi database
  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'recipe_db.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Membuat tabel-tabel yang diperlukan
  Future<void> _onCreate(Database db, int version) async {
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
    // Catatan: Untuk kesederhanaan, steps dan ingredients disimpan sebagai JSON string.
    // Untuk proyek yang lebih kompleks, buat tabel terpisah dan gunakan relasi.
  }

  // --- CRUD Operations untuk Recipe ---

  // Future, async, await: Metode ini berjalan secara asynchronous

Future<int> insertRecipe(Recipe recipe) async {
  final db = await database;
  final recipeMap = recipe.toMap();
  
  // Gunakan jsonEncode untuk mengubah list menjadi JSON string
  recipeMap['steps'] = jsonEncode(recipe.steps);
  recipeMap['ingredients'] = jsonEncode(recipe.ingredients.map((i) => i.toMap()).toList());
  
  return await db.insert('recipes', recipeMap);
}


  // di dalam class DbHelper
Future<List<Recipe>> getRecipes() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('recipes');
  return List.generate(maps.length, (i) {
    final map = maps[i];
    
    // Gunakan jsonDecode untuk mengubah JSON string kembali ke list
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

  
// di dalam class DbHelper
Future<int> updateRecipe(Recipe recipe) async {
  final db = await database;
  final recipeMap = recipe.toMap();

  // Gunakan jsonEncode di sini juga
  recipeMap['steps'] = jsonEncode(recipe.steps);
  recipeMap['ingredients'] = jsonEncode(recipe.ingredients.map((i) => i.toMap()).toList());

  return await db.update('recipes', recipeMap, where: 'id = ?', whereArgs: [recipe.id]);
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