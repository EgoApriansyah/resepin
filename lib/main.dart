import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepin/app.dart';
import 'package:resepin/features/recipe/providers/recipe_provider.dart';
import 'package:resepin/features/auth/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()..fetchRecipes()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const RecipeApp(),
    ),
  );
}