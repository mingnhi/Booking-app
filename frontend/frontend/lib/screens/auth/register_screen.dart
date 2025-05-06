import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng Ký'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            return Column(
              children: [
                if (authService.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      authService.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Họ và Tên'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Mật Khẩu'),
                  obscureText: true,
                ),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Số Điện Thoại'),
                ),
                SizedBox(height: 16),
                authService.isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () async {
                    final request = RegisterRequest(
                      fullName: _fullNameController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                      phoneNumber: _phoneNumberController.text,
                    );
                    final success = await authService.register(request);
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/auth/login');
                    }
                  },
                  child: Text('Đăng Ký'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/auth/login'),
                  child: Text('Đã có tài khoản? Đăng nhập'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}