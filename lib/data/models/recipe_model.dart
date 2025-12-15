// lib/data/models/recipe_model.dart
import 'ingredient_model.dart';
import 'dart:convert';


// Kelas Abstrak sebagai contoh Inheritance
// Semua kelas yang mengimplementasikan ini harus memiliki metode 'get title'
abstract class SearchableItem {
  String get title;
}

class Recipe implements SearchableItem {
  final int? id;
  final String name;
  final String description;
  final String category; // Bisa diubah menjadi objek Category nantinya
  final List<String> steps;
  final List<Ingredient> ingredients;
  final String imagePath;
  bool isFavorite;

  // Encapsulation: Field 'isFavorite' diatur melalui metode publik
  Recipe({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.steps,
    required this.ingredients,
    required this.imagePath,
    this.isFavorite = false,
  });

  // Polymorphism: Implementasi dari kelas abstrak SearchableItem
  @override
  String get title => name;

  // Factory constructor untuk membuat objek dari Map
  factory Recipe.fromMap(Map<String, dynamic> map) {
  return Recipe(
    id: map['id']?.toInt(),
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    category: map['category'] ?? '',
    steps: map['steps'] != null
        ? List<String>.from(jsonDecode(map['steps']))
        : [],
    ingredients: map['ingredients'] != null
        ? (jsonDecode(map['ingredients']) as List)
            .map((i) => Ingredient.fromMap(i))
            .toList()
        : [],
    imagePath: map['imagePath'] ?? 'assets/images/placeholder.jpg',
    isFavorite: map['isFavorite'] == 1,
  );
}


  // Metode untuk mengkonversi objek ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'steps': steps,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'imagePath': imagePath,
      'isFavorite': isFavorite ? 1 : 0, // Simpan boolean sebagai integer di SQLite
    };
  }
}