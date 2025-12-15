import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepin/features/recipe/providers/recipe_provider.dart';
import 'package:resepin/routes.dart';
import 'package:resepin/theme.dart';
import 'package:resepin/core/constants/app_routes.dart';


class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipeProvider()..fetchRecipes(),
      child: MaterialApp(
        title: 'Resepin',
        theme: appTheme(),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutesGenerator.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}