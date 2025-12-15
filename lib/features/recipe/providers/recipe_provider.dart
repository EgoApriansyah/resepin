// lib/features/recipe/providers/recipe_provider.dart
import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';
import '../../../core/utils/generic.dart';
import '../../../data/models/recipe_model.dart';

class RecipeProvider extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  Resource<List<Recipe>> _recipes = Resource.loading('Memuat resep...');
  List<Recipe> _favoriteRecipes = [];

  Resource<List<Recipe>> get recipes => _recipes;
  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  Future<void> fetchRecipes() async {
    _recipes = Resource.loading('Memuat resep...');
    notifyListeners();
    try {
      final result = await _dbHelper.getRecipes();
      _recipes = Resource.success(result);
      _updateFavoriteList();
    } catch (e) {
      _recipes = Resource.error('Gagal memuat resep: $e');
    }
    notifyListeners();
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _dbHelper.insertRecipe(recipe);
      fetchRecipes(); // Reload data setelah menambah
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _dbHelper.updateRecipe(recipe);
      fetchRecipes(); // Reload data setelah mengupdate
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteRecipe(int id) async {
    try {
      await _dbHelper.deleteRecipe(id);
      fetchRecipes(); // Reload data setelah menghapus
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> toggleFavorite(int recipeId) async {
    final recipeIndex = _recipes.data!.indexWhere((r) => r.id == recipeId);
    if (recipeIndex != -1) {
      final recipe = _recipes.data![recipeIndex];
      recipe.isFavorite = !recipe.isFavorite;
      await _dbHelper.updateRecipe(recipe);
      _updateFavoriteList();
      notifyListeners();
    }
  }

  void _updateFavoriteList() {
    if (_recipes.data != null) {
      _favoriteRecipes = _recipes.data!.where((r) => r.isFavorite).toList();
    }
  }
}