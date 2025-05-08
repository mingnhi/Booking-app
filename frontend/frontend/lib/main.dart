import 'package:flutter/material.dart';
import 'package:frontend/screens/admin/admin_dashboard.dart';
import 'package:frontend/screens/admin/seat_management_screen.dart';
import 'package:frontend/screens/admin/ticket_management_screen.dart';
import 'package:frontend/screens/admin/trip_create_form.dart';
import 'package:frontend/screens/admin/trip_edit_form.dart';
import 'package:frontend/screens/admin/trip_management_screen.dart';
import 'package:frontend/screens/admin/user_management_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/profile_screen.dart';
import 'package:frontend/screens/auth/register_screen.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/location/location_create_screen.dart';
import 'package:frontend/screens/location/location_edit_screen.dart';
import 'package:frontend/screens/location/location_list_screen.dart';
import 'package:frontend/screens/seat/seat_create_screen.dart';
import 'package:frontend/screens/seat/seat_edit_screen.dart';
import 'package:frontend/screens/seat/seat_list_screen.dart';
import 'package:frontend/screens/ticket/ticket_create_screen.dart';
import 'package:frontend/screens/ticket/ticket_edit_screen.dart';
import 'package:frontend/screens/ticket/ticket_list_screen.dart';
import 'package:frontend/screens/trip/trip_detail_screen.dart';
import 'package:frontend/screens/trip/trip_list_screen.dart';
import 'package:frontend/screens/trip/trip_search_screen.dart';
import 'package:frontend/screens/wait/waiting_vexere_screen.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/home_service.dart';
import 'package:frontend/services/location_service.dart';
import 'package:frontend/services/seat_service.dart';
import 'package:frontend/services/ticket_service.dart';
import 'package:frontend/services/trip_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AdminService>(create: (_) => AdminService()),
        ChangeNotifierProvider<HomeService>(create: (_) => HomeService()),
        ChangeNotifierProvider<LocationService>(create: (_) => LocationService()),
        ChangeNotifierProvider<TripService>(create: (_) => TripService()),
        ChangeNotifierProvider<SeatService>(create: (_) => SeatService()),
        ChangeNotifierProvider<TicketService>(create: (_) => TicketService()),
      ],
      child: MaterialApp(
        title: 'Đăng ký tuyến xe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2474E5),
          scaffoldBackgroundColor: const Color(0xFFF9F9F9),
          textTheme: GoogleFonts.poppinsTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2474E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 2,
            titleTextStyle: TextStyle(
              color: Color(0xFF1A2525),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const WaitingVexereScreen(),
          '/auth/login': (context) => LoginScreen(),
          '/auth/register': (context) => RegisterScreen(),
          '/auth/profile': (context) => ProfileScreen(),
          '/home': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            if (authService.isAdmin()) {
              return const AdminDashboard();
            }
            return HomeScreen();
          },
          '/admin': (context) => const AdminDashboard(),
          '/admin/seats': (context) => const SeatManagementScreen(),
          '/admin/tickets': (context) => const TicketManagementScreen(),
          '/admin/trips': (context) => const TripManagementScreen(),
          '/admin/users': (context) => const UserManagementScreen(),
          '/location': (context) => LocationListScreen(),
          '/location/create': (context) => LocationCreateScreen(),
          '/location/edit/:id': (context) {
            final id = ModalRoute.of(context)!.settings.arguments;
            if (id is String && id.isNotEmpty) {
              return LocationEditScreen(id: id);
            }
            return const Scaffold(body: Center(child: Text('ID địa điểm không hợp lệ')));
          },
          '/trip': (context) => TripListScreen(),
          '/trip/search': (context) => TripSearchScreen(),
          '/trip/detail/:id': (context) {
            final id = ModalRoute.of(context)!.settings.arguments;
            if (id is String && id.isNotEmpty) {
              return TripDetailScreen(id: id);
            }
            return const Scaffold(body: Center(child: Text('ID chuyến đi không hợp lệ')));
          },
          '/trip/create': (context) => TripCreateForm(),
          '/trip/edit/:id': (context) {
            final id = ModalRoute.of(context)!.settings.arguments;
            if (id is String && id.isNotEmpty) {
              return TripEditForm(tripData: {'_id': id});
            }
            return const Scaffold(body: Center(child: Text('ID chuyến đi không hợp lệ')));
          },
          '/seat': (context) => SeatListScreen(),
          '/seat/create': (context) => SeatCreateScreen(),
          '/seat/edit/:id': (context) {
            final id = ModalRoute.of(context)!.settings.arguments;
            if (id is String && id.isNotEmpty) {
              return SeatEditScreen(id: id);
            }
            return const Scaffold(body: Center(child: Text('ID ghế không hợp lệ')));
          },
          '/tickets': (context) => const TicketListScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Không tìm thấy trang')),
            ),
          );
        },
      ),
    );
  }
}