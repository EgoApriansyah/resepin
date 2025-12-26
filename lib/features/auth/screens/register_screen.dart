import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _handleRegister() async {
    if (_emailController.text.isEmpty || 
        _usernameController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran Berhasil! Silakan Login.'), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context); // Kembali ke halaman Login
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal Mendaftar! Email mungkin sudah digunakan.'), 
            backgroundColor: Color(0xFFFF6B6B)
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF6B6B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Akun', 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
            const Text(
              'Mulai petualangan memasakmu hari ini', 
              style: TextStyle(color: Colors.grey)
            ),
            const SizedBox(height: 40),
            
            _buildTextField('Email', Icons.email_outlined, _emailController),
            const SizedBox(height: 20),
            _buildTextField('Username', Icons.person_outline, _usernameController),
            const SizedBox(height: 20),
            _buildTextField(
              'Password', 
              Icons.lock_outline, 
              _passwordController, 
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.3),
                ),
                child: const Text(
                  'DAFTAR SEKARANG', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, 
    IconData icon, 
    TextEditingController controller, 
    {
      bool isPassword = false, 
      bool isPasswordVisible = false, 
      VoidCallback? onTogglePassword
    }
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: onTogglePassword,
            ) 
          : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide.none
        ),
      ),
    );
  }
}