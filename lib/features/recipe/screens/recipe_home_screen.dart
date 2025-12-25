import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card_widget.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/generic.dart';

class RecipeHomeScreen extends StatefulWidget {
  const RecipeHomeScreen({super.key});

  @override
  State<RecipeHomeScreen> createState() => _RecipeHomeScreenState();
}

class _RecipeHomeScreenState extends State<RecipeHomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      extendBody: true, // Agar konten mengalir di belakang navbar floating
      body: SafeArea(
        bottom: false,
        child: Consumer<RecipeProvider>(
          builder: (context, provider, child) {
            // --- LOGIKA PENGAMBILAN KATEGORI DINAMIS ---
            List<String> dynamicCategories = ['Semua'];
            if (provider.recipes.status == Status.success) {
              final recipes = provider.recipes.data!;
              // Mengambil kategori unik dari data resep yang ada
              final uniqueCats = recipes.map((r) => r.category).toSet().toList();
              dynamicCategories.addAll(uniqueCats);
            }

            // --- LOGIKA FILTER RESEP ---
            final allRecipes = provider.recipes.data ?? [];
            final filteredRecipes = _selectedCategory == 'Semua'
                ? allRecipes
                : allRecipes.where((recipe) => 
                    recipe.category.toLowerCase() == _selectedCategory.toLowerCase()
                  ).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- HEADER SECTION ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Halo, Chef! 👋', 
                                style: TextStyle(color: Colors.grey, fontSize: 14)),
                            SizedBox(height: 4),
                            Text('Resepin', 
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                          ],
                        ),
                        _buildCircleIconButton(Icons.notifications_none, () {}),
                      ],
                    ),
                  ),
                ),

                // --- SEARCH BAR (Navigasi ke SearchScreen) ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Color(0xFFFF6B6B)),
                            SizedBox(width: 12),
                            Text('Cari resep favoritmu...', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // --- KATEGORI DINAMIS (Berdasarkan Data Resep) ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: dynamicCategories.length,
                      itemBuilder: (context, index) {
                        final catName = dynamicCategories[index];
                        return _buildCategoryChip(
                          catName, 
                          _selectedCategory == catName,
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 25)),

                // --- CONTENT LIST ---
                if (provider.recipes.status == Status.loading)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                else if (provider.recipes.status == Status.error)
                  SliverFillRemaining(child: Center(child: Text(provider.recipes.message!)))
                else if (filteredRecipes.isEmpty)
                  _buildEmptyState()
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RecipeCardWidget(recipe: filteredRecipes[index]),
                        ),
                        childCount: filteredRecipes.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B6B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
          boxShadow: isSelected 
              ? [BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
          _navItem(Icons.home_filled, "Home", 0, () => setState(() => _currentIndex = 0)),
          _navItem(Icons.favorite_rounded, "Favorites", 1, () => Navigator.pushNamed(context, AppRoutes.favorites)),
          _buildCenterAddButton(),
          _navItem(Icons.bar_chart_rounded, "Stats", 2, () => Navigator.pushNamed(context, AppRoutes.stats)),
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

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.addEditRecipe),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [Color(0xFF8EAAFB), Color(0xFF6486F6)]),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: IconButton(icon: Icon(icon, color: Colors.black), onPressed: onTap),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Tidak ada resep di kategori ini.', style: TextStyle(color: Colors.grey)),
          TextButton(
            onPressed: () => setState(() => _selectedCategory = 'Semua'),
            child: const Text('Lihat Semua'),
          )
        ],
      ),
    );
  }
}