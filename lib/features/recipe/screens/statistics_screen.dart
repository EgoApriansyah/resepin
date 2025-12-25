import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/generic.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Index 2 untuk menu Statistik
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Statistik Resep',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          if (provider.recipes.status == Status.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRecipes = provider.recipes.data ?? [];
          final totalRecipes = allRecipes.length;
          final totalFavorites = provider.favoriteRecipes.length;

          // Hitung distribusi kategori
          Map<String, int> categoryDist = {};
          for (var r in allRecipes) {
            categoryDist[r.category] = (categoryDist[r.category] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. RINGKASAN KOTAK (CARDS)
                Row(
                  children: [
                    _buildStatCard(
                      'Total Resep',
                      totalRecipes.toString(),
                      Icons.restaurant_menu,
                      const Color(0xFF6486F6),
                    ),
                    const SizedBox(width: 15),
                    _buildStatCard(
                      'Favorit',
                      totalFavorites.toString(),
                      Icons.favorite,
                      const Color(0xFFFF6B6B),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                const Text(
                  'Distribusi Kategori',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // 2. LIST PROGRES KATEGORI
                if (allRecipes.isEmpty)
                  const Center(child: Text('Belum ada data resep'))
                else
                  ...categoryDist.entries.map((entry) {
                    double percentage = entry.value / totalRecipes;
                    return _buildCategoryProgress(entry.key, entry.value, percentage);
                  }).toList(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(String label, int count, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('$count Resep', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[100],
            color: const Color(0xFF6486F6),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavbar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_filled, "Home", 0, () => Navigator.pushReplacementNamed(context, AppRoutes.home)),
          _navItem(Icons.favorite_rounded, "Favorites", 1, () => Navigator.pushReplacementNamed(context, AppRoutes.favorites)),
          
          // Add Button
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.addEditRecipe),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF8EAAFB), Color(0xFF6486F6)]),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          
          _navItem(Icons.bar_chart_rounded, "Stats", 2, () {}),
          _navItem(Icons.person_rounded, "Profile", 3, () {}),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, VoidCallback onTap) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF6486F6) : Colors.grey.shade300, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.black : Colors.grey.shade400)),
        ],
      ),
    );
  }
}