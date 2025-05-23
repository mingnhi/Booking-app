import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/auth.dart';
import '../../services/auth_service.dart';
import '../home/customer_nav_bar.dart'; // Import CustomNavBar

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  int _selectedIndex = 3; // Chỉ số hiện tại của thanh điều hướng (Tài khoản)
  bool _isEditing = false;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent,
      statusBarIconBrightness: Brightness.light,
    ));

    Future.microtask(() {
      if (mounted) {
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        );
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
        );
        _animationController!.forward();
      }
    });

    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.getProfile().then((_) {
        if (authService.currentUser != null) {
          _fullNameController.text = authService.currentUser!.fullName;
          _emailController.text = authService.currentUser!.email;
          _phoneController.text = authService.currentUser!.phoneNumber ?? '';
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/trip/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/my-tickets');
        break;
      case 3:
        break;
    }
  }

  Future<void> _updateProfile(AuthService authService) async {
    final url = Uri.parse('${authService.baseUrl}/users/${authService.currentUser!.id}');
    final token = await authService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy token đăng nhập')),
      );
      return;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'full_name': _fullNameController.text,
          'email': _emailController.text,
          'phone_number': _phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        authService.currentUser = User.fromJson(data); // Sửa lại: không cần data['user']
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!')),
        );
        setState(() {
          _isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/vexere_logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.blueAccent.shade100.withOpacity(0.8),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/auth/login');
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.white],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Consumer<AuthService>(
            builder: (context, authService, _) {
              if (authService.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (authService.errorMessage != null) {
                return Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation!,
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/auth/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              if (_fadeAnimation == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.blueAccent.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 32),
                      Card(
                        elevation: 12,
                        shadowColor: Colors.blueAccent.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.blueAccent.shade100.withOpacity(0.5), width: 1),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_isEditing) ...[
                                _buildProfileItem(
                                  icon: Icons.person,
                                  title: 'Họ và Tên',
                                  value: authService.currentUser!.fullName,
                                ),
                                const SizedBox(height: 16),
                                _buildProfileItem(
                                  icon: Icons.email,
                                  title: 'Email',
                                  value: authService.currentUser!.email,
                                ),
                                const SizedBox(height: 16),
                                _buildProfileItem(
                                  icon: Icons.phone,
                                  title: 'Số Điện Thoại',
                                  value: authService.currentUser!.phoneNumber ?? 'Không có dữ liệu',
                                ),
                                const SizedBox(height: 16),
                                _buildProfileItem(
                                  icon: Icons.admin_panel_settings,
                                  title: 'Vai Trò',
                                  value: authService.currentUser!.role,
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent.shade400,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      'Chỉnh Sửa',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                _buildEditableField(
                                  controller: _fullNameController,
                                  label: 'Họ và Tên',
                                  icon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập họ và tên';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildEditableField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email,
                                  validator: (value) {
                                    if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                      return 'Vui lòng nhập email hợp lệ';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildEditableField(
                                  controller: _phoneController,
                                  label: 'Số Điện Thoại',
                                  icon: Icons.phone,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(value)) {
                                      return 'Số điện thoại phải có 10 chữ số';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = false;
                                          _fullNameController.text = authService.currentUser!.fullName;
                                          _emailController.text = authService.currentUser!.email;
                                          _phoneController.text = authService.currentUser!.phoneNumber ?? '';
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade400,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: Text(
                                        'Hủy',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_fullNameController.text.isEmpty ||
                                            _emailController.text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
                                          );
                                          return;
                                        }
                                        _updateProfile(authService);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent.shade400,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: Text(
                                        'Lưu',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Đăng Xuất',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
        const SizedBox(width: 12),
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
              const SizedBox(height: 4),
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

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.blueGrey.shade800,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent.shade400, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.blueAccent.shade400),
      ),
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.blueGrey.shade800,
      ),
      validator: validator,
    );
  }
}