import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepin/core/utils/generic.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../../recipe/widgets/recipe_card_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    // Ambil daftar kategori unik dari provider
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    if (provider.recipes.status == Status.success) {
      final recipes = provider.recipes.data!;
      _categories = recipes.map((r) => r.category).toSet().toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian Resep'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari resep atau bahan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
              ),
              onChanged: (value) {
                // Trigger rebuild untuk menampilkan hasil pencarian
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(category),
                    onSelected: (isSelected) {
                      // Logika filter berdasarkan kategori bisa ditambahkan di sini
                      // Untuk sekarang, kita hanya akan menambahkannya ke pencarian
                      _searchController.text = category;
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 32),
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, provider, child) {
                if (provider.recipes.status != Status.success) {
                  return const Center(child: Text('Tidak ada data untuk dicari.'));
                }

                final allRecipes = provider.recipes.data!;
                final query = _searchController.text.toLowerCase();
                
                final filteredRecipes = allRecipes.where((recipe) {
                  final nameLower = recipe.name.toLowerCase();
                  final categoryLower = recipe.category.toLowerCase();
                  final ingredientsLower = recipe.ingredients.map((i) => i.name.toLowerCase()).join(' ');
                  return nameLower.contains(query) ||
                         categoryLower.contains(query) ||
                         ingredientsLower.contains(query);
                }).toList();

                if (filteredRecipes.isEmpty) {
                  return const Center(child: Text('Tidak ada resep ditemukan.'));
                }

                return ListView.builder(
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    return RecipeCardWidget(recipe: filteredRecipes[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}