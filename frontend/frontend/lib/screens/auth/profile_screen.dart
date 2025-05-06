import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hồ sơ')),
      body: Consumer<AuthService>(
        builder: (context, authService, _) {
          if (authService.isLoading) return Center(child: CircularProgressIndicator());
          return FutureBuilder<User?>(
            future: authService.getProfile(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: Text('Không tìm thấy dữ liệu'));
              final user = snapshot.data!;
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Họ tên: ${user.fullName}'),
                    Text('Email: ${user.email}'),
                    Text('Số điện thoại: ${user.phoneNumber ?? 'Không có'}'),
                    Text('Vai trò: ${user.role}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await authService.logout();
                        Navigator.pushReplacementNamed(context, '/auth/login');
                      },
                      child: Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}