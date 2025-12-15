import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class RecipeCardWidget extends StatelessWidget {
  final Recipe recipe;

  const RecipeCardWidget({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/recipe-detail', arguments: recipe);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                recipe.imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.restaurant, color: Colors.grey, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Consumer<RecipeProvider>(
                    builder: (context, provider, child) {
                      return IconButton(
                        icon: Icon(
                          recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          provider.toggleFavorite(recipe.id!);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}