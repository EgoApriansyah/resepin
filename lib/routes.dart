import 'package:flutter/material.dart';
import 'package:resepin/features/recipe/screens/add_edit_recipe_screen.dart';
import 'package:resepin/features/recipe/screens/interactive_cooking_screen.dart';
import 'package:resepin/features/recipe/screens/recipe_detail_screen.dart';
import 'package:resepin/features/recipe/screens/recipe_home_screen.dart';
import 'package:resepin/features/search/screens/search_screen.dart';
import 'package:resepin/features/favorite/screens/favorite_screen.dart';
import 'core/constants/app_routes.dart';
import 'package:resepin/data/models/recipe_model.dart';

class AppRoutesGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const RecipeHomeScreen());

      case AppRoutes.addEditRecipe:
        final args = settings.arguments as Recipe?;
        return MaterialPageRoute(
          builder: (_) => AddEditRecipeScreen(recipe: args),
        );

      case AppRoutes.recipeDetail:
        final args = settings.arguments as Recipe;
        return MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: args),
        );

      case AppRoutes.interactiveCooking:
        final args = settings.arguments as Recipe;
        return MaterialPageRoute(
          builder: (_) => InteractiveCookingScreen(recipe: args),
        );

      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case AppRoutes.favorites:
        return MaterialPageRoute(builder: (_) => const FavoriteScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
    }
  }
}
