import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VexereScreen extends StatelessWidget {
  const VexereScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF1A73E8), // Màu nền xanh giống trong hình
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/vexere_logo.jpg', // Đường dẫn đến ảnh logo của bạn
                width: 300, // Điều chỉnh kích thước logo nếu cần
                height: 100,
              ),
              Text(
                'Khởi đầu suốn sẻ cho hành trình trọn vẹn',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500, // Độ dày trung bình
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}