import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../../recipe/widgets/recipe_card_widget.dart';
import '../../../core/constants/app_routes.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // Set index ke 1 karena ini adalah halaman Favorites
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      extendBody: true, // Agar list resep terlihat di belakang navbar
      
      // 1. CUSTOM APP BAR (Tanpa Background Solid)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Resep Favorit',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      ),

      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          final favoriteRecipes = provider.favoriteRecipes;

          if (favoriteRecipes.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            // Padding bawah extra (120) agar resep terakhir tidak tertutup Navbar
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            physics: const BouncingScrollPhysics(),
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecipeCardWidget(recipe: favoriteRecipes[index]),
              );
            },
          );
        },
      ),

      // 2. FLOATING NAVBAR (Sama dengan Home)
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildFloatingNavbar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_filled, "Home", 0, () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }),
          _navItem(Icons.favorite_rounded, "Favorites", 1, () {
            // Sudah di halaman favorit
          }),
          
          // Tombol Center Add
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
          Icon(
            icon, 
            color: isSelected ? const Color(0xFF6486F6) : Colors.grey.shade300, 
            size: 26
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              fontSize: 10, 
              color: isSelected ? Colors.black : Colors.grey.shade400,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border_rounded, size: 80, color: Colors.red[200]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada resep favorit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Simpan resep yang kamu suka di sini!',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text('Cari Resep', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}