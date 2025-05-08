import 'package:flutter/material.dart';
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
import 'package:frontend/screens/trip/trip_create_screen.dart';
import 'package:frontend/screens/trip/trip_detail_screen.dart';
import 'package:frontend/screens/trip/trip_edit_screen.dart';
import 'package:frontend/screens/trip/trip_list_screen.dart';
import 'package:frontend/screens/trip/trip_search_screen.dart';
import 'package:frontend/screens/wait/waiting_vexere_screen.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/home_service.dart';
import 'package:frontend/services/location_service.dart';
import 'package:frontend/services/seat_service.dart';
import 'package:frontend/services/trip_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/admin/admin_dashboard.dart';
import 'package:frontend/screens/admin/trip_create_form.dart';
import 'package:frontend/screens/admin/trip_edit_form.dart';
import 'package:frontend/screens/admin/trip_management_screen.dart';

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
        ChangeNotifierProvider<HomeService>(create: (_) => HomeService()),
        ChangeNotifierProvider<LocationService>(
          create: (_) => LocationService(),
        ),
        ChangeNotifierProvider<TripService>(create: (_) => TripService()),
        ChangeNotifierProvider<SeatService>(create: (_) => SeatService()),
        ChangeNotifierProvider<AdminService>(create: (_) => AdminService()),
      ],
      child: MaterialApp(
        title: 'Ứng dụng đặt vé xe',
        initialRoute: '/splash', // Đặt VexereScreen làm màn hình khởi động
        routes: {
          '/splash': (context) => const WaitingVexereScreen(),
          '/auth/login': (context) => LoginScreen(),
          '/auth/register': (context) => RegisterScreen(),
          '/auth/profile': (context) => ProfileScreen(),
          '/home': (context) => HomeScreen(),
          '/location': (context) => LocationListScreen(),
          '/location/create': (context) => LocationCreateScreen(),
          '/location/edit/:id':
              (context) => LocationEditScreen(
                id: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/trip': (context) => TripListScreen(),
          '/trip/search': (context) => TripSearchScreen(),
          '/trip/detail/:id':
              (context) => TripDetailScreen(
                id: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/trip/create': (context) => TripCreateScreen(),
          '/trip/edit/:id':
              (context) => TripEditScreen(
                id: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/seat': (context) => SeatListScreen(),
          '/seat/create': (context) => SeatCreateScreen(),
          '/seat/edit/:id':
              (context) => SeatEditScreen(
                id: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/splash': (context) => const WaitingVexereScreen(),
          '/auth/login': (context) => LoginScreen(),
          '/auth/register': (context) => RegisterScreen(),
          '/auth/profile': (context) => ProfileScreen(),
          '/home': (context) => HomeScreen(),
          '/admin': (context) => AdminDashboard(), // Thêm route admin
          '/admin/trips': (context) => TripManagementScreen(),
          '/admin/trips/create': (context) => TripCreateForm(),
          '/admin/trips/edit/:id': (context) {
            final tripId = ModalRoute.of(context)!.settings.arguments as String;
            return TripEditForm(tripData: {'_id': tripId});
          },
        },
      ),
    );
  }
}
