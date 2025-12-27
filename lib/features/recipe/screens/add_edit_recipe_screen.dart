import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart'; // Pastikan path benar
import '../providers/recipe_provider.dart';
import 'package:resepin/data/models/recipe_model.dart';
import 'package:resepin/data/models/ingredient_model.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  String? _imagePath;

  List<String> _steps = [''];
  List<Ingredient> _ingredients = [Ingredient(name: '', amount: 0, unit: '')];

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _nameController = TextEditingController(text: recipe?.name ?? '');
    _descriptionController = TextEditingController(text: recipe?.description ?? '');
    _categoryController = TextEditingController(text: recipe?.category ?? '');
    _imagePath = (recipe != null && recipe.imagePath != 'assets/images/placeholder.jpg') 
        ? recipe.imagePath : null;

    if (recipe != null) {
      _steps = List.from(recipe.steps);
      _ingredients = List.from(recipe.ingredients);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final newRecipe = Recipe(
        id: widget.recipe?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        steps: _steps.where((s) => s.trim().isNotEmpty).toList(),
        ingredients: _ingredients.where((i) => i.name.trim().isNotEmpty).toList(),
        imagePath: _imagePath ?? 'assets/images/placeholder.jpg',
        isFavorite: widget.recipe?.isFavorite ?? false,
      );

      if (widget.recipe == null) {
        context.read<RecipeProvider>().addRecipe(newRecipe);
      } else {
        context.read<RecipeProvider>().updateRecipe(newRecipe);
      }
      Navigator.pop(context);
    }
  }

  // Helper untuk Decorasi Input ala Dribbble
  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.recipe == null ? 'Buat Resep Baru' : 'Edit Resep',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Picker Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _imagePath != null
                        ? (_imagePath!.startsWith('assets/')
                            ? Image.asset(_imagePath!, fit: BoxFit.cover)
                            : Image.file(File(_imagePath!), fit: BoxFit.cover))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo_rounded, size: 50, color: AppColors.primary),
                              SizedBox(height: 8),
                              Text('Tambahkan Foto Masakan', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 2. Info Utama Section
              _sectionTitle("Informasi Umum"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecor('Nama Masakan', Icons.restaurant_menu),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _categoryController,
                decoration: _inputDecor('Kategori (Contoh: Dessert)', Icons.category_outlined),
                validator: (v) => v!.isEmpty ? 'Kategori wajib diisi' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecor('Ceritakan sedikit tentang resep ini...', Icons.description_outlined),
              ),
              const SizedBox(height: 30),

              // 3. Ingredients Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle("Bahan-bahan"),
                  TextButton.icon(
                    onPressed: () => setState(() => _ingredients.add(Ingredient(name: '', amount: 0, unit: ''))),
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    label: const Text('Tambah', style: TextStyle(color: AppColors.primary)),
                  )
                ],
              ),
              ...List.generate(_ingredients.length, (index) => _buildIngredientRow(index)),
              const SizedBox(height: 30),

              // 4. Steps Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle("Langkah Memasak"),
                  TextButton.icon(
                    onPressed: () => setState(() => _steps.add('')),
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    label: const Text('Tambah', style: TextStyle(color: AppColors.primary)),
                  )
                ],
              ),
              ...List.generate(_steps.length, (index) => _buildStepRow(index)),
              
              const SizedBox(height: 40),

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: const Text('Simpan Resep Lezat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildIngredientRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: _ingredients[index].name,
              decoration: const InputDecoration(hintText: 'Nama Bahan', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 10)),
              onChanged: (v) => _ingredients[index] = _ingredients[index].copyWith(name: v),
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: _ingredients[index].amount == 0 ? '' : _ingredients[index].amount.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'Jml', border: InputBorder.none),
              onChanged: (v) => _ingredients[index] = _ingredients[index].copyWith(amount: double.tryParse(v) ?? 0),
            ),
          ),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: _ingredients[index].unit,
              decoration: const InputDecoration(hintText: 'Unit', border: InputBorder.none),
              onChanged: (v) => _ingredients[index] = _ingredients[index].copyWith(unit: v),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
            onPressed: () => setState(() => _ingredients.removeAt(index)),
          )
        ],
      ),
    );
  }

  Widget _buildStepRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text('${index + 1}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: _steps[index],
              maxLines: null,
              decoration: _inputDecor('Langkah ke-${index + 1}', Icons.edit_note).copyWith(prefixIcon: null),
              onChanged: (v) => _steps[index] = v,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.only(top: 12),
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () => setState(() => _steps.removeAt(index)),
          )
        ],
      ),
    );
  }
}