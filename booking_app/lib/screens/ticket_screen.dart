import 'package:flutter/material.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A73E8),
        title: const Text('Vé của tôi', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {},
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1A73E8),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Hiện tại'),
              Tab(text: 'Đã đi'),
              Tab(text: 'Đã hủy'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Nội dung cho tab "Hiện tại"
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/skyline.jpg',
                        width: 400,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                // Nội dung cho tab "Đã đi"
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/skyline.jpg',
                        width: 400,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                // Nội dung cho tab "Đã hủy"
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/skyline.jpg',
                        width: 400,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Vé của tôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: 1, // Đặt tab "Vé của tôi" là tab mặc định
        selectedItemColor: const Color(0xFF1A73E8),
        unselectedItemColor: const Color(0xFF1A73E8), // Đặt màu cho icon không được chọn
        onTap: (index) {
          // Xử lý khi nhấn vào các tab
        },
      ),
    );
  }
}