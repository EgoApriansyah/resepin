import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';

class AuthProvider extends ChangeNotifier {
  // Simpan data user yang sedang login dalam bentuk Map
  Map<String, dynamic>? _user;
  
  // Getter untuk mengambil data user
  Map<String, dynamic>? get user => _user;
  
  // Status apakah user sudah login
  bool get isLoggedIn => _user != null;

  final DbHelper _dbHelper = DbHelper();

  // ==========================================
  // --- FUNGSI REGISTRASI ---
  // ==========================================
  Future<bool> register({
    required String email, 
    required String username, 
    required String password
  }) async {
    try {
      await _dbHelper.registerUser({
        'email': email,
        'username': username,
        'password': password,
        'photoPath': '', // Default kosong saat daftar
      });
      return true;
    } catch (e) {
      debugPrint("Error Register: $e");
      return false;
    }
  }

  // ==========================================
  // --- FUNGSI LOGIN ---
  // ==========================================
  Future<bool> login(String email, String password) async {
    try {
      final userData = await _dbHelper.loginUser(email, password);
      if (userData != null) {
        _user = userData;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Login: $e");
      return false;
    }
  }

  // ==========================================
  // --- FUNGSI UPDATE FOTO PROFIL ---
  // ==========================================
  Future<void> updateProfilePhoto(String path) async {
    if (_user == null) return;
    
    try {
      final userId = _user!['id'];
      // Update di Database
      await _dbHelper.updateUserPhoto(userId, path);
      
      // Update state user lokal agar UI langsung berubah
      // Kita buat map baru agar notifyListeners() mendeteksi perubahan
      final updatedUser = Map<String, dynamic>.from(_user!);
      updatedUser['photoPath'] = path;
      _user = updatedUser;
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error Update Photo: $e");
    }
  }

  // ==========================================
  // --- FUNGSI LOGOUT ---
  // ==========================================
  void logout() {
    _user = null;
    notifyListeners();
  }
}