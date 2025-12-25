import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepin/data/models/recipe_model.dart';
import '../../../core/constants/app_routes.dart';
import '../providers/recipe_provider.dart';
// Import yang diperlukan untuk memuat gambar dari File
import 'dart:io'; 

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  // Fungsi Pembantu untuk menentukan jenis gambar
  Widget _buildDetailImage(String imagePath) {
    // 1. Cek apakah path diawali dengan 'assets/' (path statis)
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        // ErrorBuilder untuk asset
        errorBuilder: (c, o, s) => Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
        ),
      );
    } 
    // 2. Jika bukan 'assets/', anggap sebagai path file lokal (dinamis)
    else if (imagePath.isNotEmpty) {
      final file = File(imagePath);
      // Memeriksa apakah file ada sebelum mencoba memuat
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
        );
      }
    }
    
    // 3. Placeholder default jika path tidak valid atau kosong
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.restaurant, size: 80, color: Colors.grey)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                // Pastikan teks terlihat di atas gambar
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, 
                  shadows: const [
                    Shadow(blurRadius: 4, color: Colors.black54)
                  ]
                ),
              ),
              background: _buildDetailImage(recipe.imagePath), // <--- Menggunakan fungsi baru
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.addEditRecipe, arguments: recipe);
                },
              ),
              Consumer<RecipeProvider>(
                builder: (context, provider, child) {
                  return IconButton(
                    icon: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    onPressed: () {
                      provider.toggleFavorite(recipe.id!);
                    },
                  );
                },
              ),
              PopupMenuButton(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Hapus Resep'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoChip('Kategori', recipe.category),
                  const SizedBox(height: 16),
                  Text(
                    'Deskripsi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(recipe.description, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Text(
                    'Bahan-bahan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8),
                        const SizedBox(width: 8),
                        Text('${ingredient.amount} ${ingredient.unit} ${ingredient.name}'),
                      ],
                    ),
                  )).toList(),
                  const SizedBox(height: 24),
                  Text(
                    'Langkah Memasak',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...recipe.steps.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(step)),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Mulai Memasak'),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.interactiveCooking, arguments: recipe);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Colors.grey[200],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: const Text('Apakah Anda yakin ingin menghapus resep ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () {
              // Menggunakan Consumer untuk mendapatkan provider saat dialog dibangun
              Provider.of<RecipeProvider>(context, listen: false).deleteRecipe(recipe.id!);
              Navigator.of(ctx).pop(); // Tutup dialog
              Navigator.of(context).pop(); // Kembali ke halaman sebelumnya (Recipe Home Screen)
            },
          ),
        ],
      ),
    );
  }
}     