import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card_widget.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/generic.dart';

class RecipeHomeScreen extends StatelessWidget {
  const RecipeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resepin',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.favorites);
            },
          ),
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          // Menggunakan Resource untuk menangani status loading, error, dan sukses
          if (provider.recipes.status == Status.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.recipes.status == Status.error) {
            return Center(child: Text(provider.recipes.message!));
          }
          if (provider.recipes.status == Status.success && provider.recipes.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Belum ada resep', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          final recipes = provider.recipes.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return RecipeCardWidget(recipe: recipes[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addEditRecipe);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}