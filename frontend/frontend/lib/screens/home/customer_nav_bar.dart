import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/ticket_service.dart';

class CustomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2474E5),
        unselectedItemColor: const Color(0xFF607D8B),
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        elevation: 8.0,
        items: [
          BottomNavigationBarItem(
            icon: AnimatedScale(
              scale: widget.currentIndex == 0 ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.home_filled),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: AnimatedScale(
              scale: widget.currentIndex == 1 ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.search),
            ),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Consumer<TicketService>(
              builder: (context, ticketService, _) {
                int ticketCount = ticketService.tickets.length;
                return Stack(
                  children: [
                    AnimatedScale(
                      scale: widget.currentIndex == 2 ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.airline_seat_recline_normal),
                    ),
                    if (ticketCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$ticketCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Vé của tôi',
          ),
          BottomNavigationBarItem(
            icon: AnimatedScale(
              scale: widget.currentIndex == 3 ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.person),
            ),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}