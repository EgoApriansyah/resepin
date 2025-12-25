// lib/features/recipe/widgets/recipe_card_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // Import ini
import '../../../data/models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class RecipeCardWidget extends StatelessWidget {
  final Recipe recipe;

  const RecipeCardWidget({super.key, required this.recipe});

  // Fungsi pembantu untuk menentukan jenis gambar
  Widget _buildRecipeImage(String imagePath) {
    // 1. Cek apakah path diawali dengan 'assets/' (path statis)
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, o, s) => Container(
          height: 150,
          color: Colors.grey[200],
          child: const Icon(Icons.restaurant, color: Colors.grey, size: 50),
        ),
      );
    } 
    // 2. Jika bukan 'assets/', anggap sebagai path file lokal (dinamis)
    else if (imagePath.isNotEmpty) {
      final file = File(imagePath);
      // Memeriksa apakah file ada secara sinkron (untuk keamanan, meskipun biasanya path dari ImagePicker valid)
      if (file.existsSync()) {
        return Image.file(
          file,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          // Tidak perlu errorBuilder, karena Image.file akan gagal jika file tidak ada
        );
      }
    }
    
    // 3. Placeholder jika path kosong atau file tidak ditemukan
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.restaurant, color: Colors.grey, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Pastikan rute '/recipe-detail' sudah didefinisikan di AppRoutes Anda
          Navigator.pushNamed(context, '/recipe-detail', arguments: recipe);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              // *** Panggil fungsi baru di sini ***
              child: _buildRecipeImage(recipe.imagePath),
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
                          if (recipe.id != null) {
                            provider.toggleFavorite(recipe.id!);
                          }
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