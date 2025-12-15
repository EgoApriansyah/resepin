import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../../recipe/widgets/recipe_card_widget.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep Favorit'),
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          final favoriteRecipes = provider.favoriteRecipes;

          if (favoriteRecipes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada resep favorit', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              return RecipeCardWidget(recipe: favoriteRecipes[index]);
            },
          );
        },
      ),
    );
  }
}