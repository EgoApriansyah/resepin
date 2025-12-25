// lib/features/recipe/screens/add_edit_recipe_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import 'package:resepin/data/models/recipe_model.dart';
import 'package:resepin/data/models/ingredient_model.dart';
// Tambahkan import ini
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  
  // Ubah dari TextEditingController menjadi String?
  String? _imagePath; // Menyimpan path file gambar lokal

  List<String> _steps = [''];
  List<Ingredient> _ingredients = [Ingredient(name: '', amount: 0, unit: '')];

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _nameController = TextEditingController(text: recipe?.name ?? '');
    _descriptionController = TextEditingController(text: recipe?.description ?? '');
    _categoryController = TextEditingController(text: recipe?.category ?? '');
    
    // Inisialisasi _imagePath dari data resep yang ada
    if (recipe != null && recipe.imagePath != 'assets/images/placeholder.jpg') {
      _imagePath = recipe.imagePath;
    } else {
      _imagePath = null;
    }

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
  
  // *** FUNGSI BARU: Pilih Gambar ***
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      // Tentukan path gambar yang akan disimpan. Gunakan placeholder jika kosong.
      final imageToSave = _imagePath ?? 'assets/images/placeholder.jpg';
      
      final newRecipe = Recipe(
        id: widget.recipe?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        steps: _steps.where((s) => s.isNotEmpty).toList(),
        ingredients: _ingredients.where((i) => i.name.isNotEmpty).toList(),
        // Gunakan path gambar yang baru
        imagePath: imageToSave, 
        isFavorite: widget.recipe?.isFavorite ?? false,
      );

      if (widget.recipe == null) {
        Provider.of<RecipeProvider>(context, listen: false).addRecipe(newRecipe);
      } else {
        Provider.of<RecipeProvider>(context, listen: false).updateRecipe(newRecipe);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Tambah Resep' : 'Edit Resep'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Resep'),
                validator: (value) => value == null || value.isEmpty ? 'Masukkan nama resep' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Masukkan deskripsi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) => value == null || value.isEmpty ? 'Masukkan kategori' : null,
              ),
              const SizedBox(height: 16),
              
              // *** Ganti TextFormField untuk Path Gambar dengan Tombol Pilih Gambar ***
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Pratinjau Gambar yang Dipilih
                    if (_imagePath != null) ...[
                      // Cek apakah path adalah path file lokal atau path asset
                      _imagePath!.startsWith('assets/')
                          ? Image.asset(
                              _imagePath!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_imagePath!),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                      const SizedBox(height: 8),
                    ],
                    
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: Text(_imagePath != null ? 'Ubah Gambar' : 'Pilih Gambar dari Galeri'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _imagePath != null 
                        ? 'Gambar Terpilih: ${_imagePath!.split('/').last}'
                        : 'Belum ada gambar yang dipilih',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // *** Bagian Bahan-bahan ***
              Text('Bahan-bahan', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...List.generate(_ingredients.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: _ingredients[index].name,
                        decoration: const InputDecoration(labelText: 'Nama Bahan'),
                        onChanged: (value) => _ingredients[index] = _ingredients[index].copyWith(name: value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: _ingredients[index].amount.toString(),
                        decoration: const InputDecoration(labelText: 'Jumlah'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _ingredients[index] = _ingredients[index].copyWith(amount: double.tryParse(value) ?? 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: _ingredients[index].unit,
                        decoration: const InputDecoration(labelText: 'Satuan'),
                        onChanged: (value) => _ingredients[index] = _ingredients[index].copyWith(unit: value),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _ingredients.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              }),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Bahan'),
                onPressed: () {
                  setState(() {
                    _ingredients.add(Ingredient(name: '', amount: 0, unit: ''));
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // *** Bagian Langkah-langkah ***
              Text('Langkah-langkah', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...List.generate(_steps.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _steps[index],
                        decoration: InputDecoration(
                          labelText: 'Langkah ${index + 1}',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 2,
                        onChanged: (value) => _steps[index] = value,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _steps.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              }),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Langkah'),
                onPressed: () {
                  setState(() {
                    _steps.add('');
                  });
                },
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: const Text('Simpan Resep'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}