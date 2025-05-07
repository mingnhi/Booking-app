import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.getProfile();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Hồ Sơ Người Dùng',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent.shade100.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/auth/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          top: true, // Ensure content starts below AppBar and status bar
          bottom: false,
          child: Consumer<AuthService>(
            builder: (context, authService, _) {
              if (authService.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (authService.errorMessage != null) {
                return Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          authService.errorMessage!,
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/auth/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade400,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Đăng Nhập Lại',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (authService.currentUser == null) {
                return Center(
                  child: Text(
                    'Không thể tải thông tin người dùng.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 16), // Additional spacing below AppBar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.blueAccent.shade400,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        authService.currentUser!.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      Text(
                        'Thông tin cá nhân của bạn',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 32),
                      Card(
                        elevation: 12,
                        shadowColor: Colors.blueAccent.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.blueAccent.shade100.withOpacity(0.5), width: 1),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileItem(
                                icon: Icons.email,
                                title: 'Email',
                                value: authService.currentUser!.email,
                              ),
                              SizedBox(height: 16),
                              _buildProfileItem(
                                icon: Icons.phone,
                                title: 'Số Điện Thoại',
                                value: authService.currentUser!.phoneNumber ?? 'Không có dữ liệu',
                              ),
                              SizedBox(height: 16),
                              _buildProfileItem(
                                icon: Icons.admin_panel_settings,
                                title: 'Vai Trò',
                                value: authService.currentUser!.role,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await authService.logout();
                            Navigator.pushReplacementNamed(context, '/auth/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Đăng Xuất',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blueAccent.shade400,
          size: 24,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}