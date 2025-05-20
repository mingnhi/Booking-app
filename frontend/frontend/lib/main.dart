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
import 'package:frontend/screens/ticket/ticket_screen.dart';
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
import 'package:frontend/services/vehicle_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_prompt_screen.dart';

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
        ChangeNotifierProvider<VehicleService>(create: (_) => VehicleService()),
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
          '/splash': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            final storage = FlutterSecureStorage();
            Future.delayed(const Duration(seconds: 3), () async {
              // Chờ AuthService khôi phục trạng thái
              if (authService.currentUser != null) {
                String? currentRoute = await storage.read(key: 'currentRoute');
                print('Restored route: $currentRoute, user: ${authService.currentUser?.fullName}');
                if (currentRoute != null && _isValidRoute(currentRoute)) {
                  Navigator.pushReplacementNamed(context, currentRoute);
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            });
            return const WaitingVexereScreen();
          },
          '/auth/login': (context) => LoginScreen(),
          '/auth/register': (context) => RegisterScreen(),
          '/auth/profile': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null
                ? ProfileScreen()
                : const LoginPromptScreen();
          },
          '/auth/login_prompt': (context) => const LoginPromptScreen(),
          '/home': (context) => HomeScreen(),
          '/admin': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null && authService.isAdmin()
                ? const AdminDashboard()
                : const LoginPromptScreen();
          },
          '/admin/seats': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null && authService.isAdmin()
                ? const SeatManagementScreen()
                : const LoginPromptScreen();
          },
          '/admin/tickets': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null && authService.isAdmin()
                ? const TicketManagementScreen()
                : const LoginPromptScreen();
          },
          '/admin/trips': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null && authService.isAdmin()
                ? const TripManagementScreen()
                : const LoginPromptScreen();
          },
          '/admin/users': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null && authService.isAdmin()
                ? const UserManagementScreen()
                : const LoginPromptScreen();
          },
          '/trip/create': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null && authService.isAdmin()
                ? TripCreateForm()
                : const LoginPromptScreen();
          },
          '/trip/edit': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            final tripData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            if (authService.currentUser != null && authService.isAdmin() && tripData != null && tripData['_id'] != null) {
              return TripEditForm(tripData: tripData);
            }
            return const Scaffold(body: Center(child: Text('Dữ liệu chuyến đi không hợp lệ hoặc quyền truy cập bị từ chối')));
          },
          '/location': (context) => LocationListScreen(),
          '/location/create': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null && authService.isAdmin()
                ? LocationCreateScreen()
                : const LoginPromptScreen();
          },
          '/location/edit/:id': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            final id = ModalRoute.of(context)!.settings.arguments as String?;
            if (authService.currentUser != null && authService.isAdmin() && id != null && id.isNotEmpty) {
              return LocationEditScreen(id: id);
            }
            return const Scaffold(body: Center(child: Text('ID địa điểm không hợp lệ hoặc quyền truy cập bị từ chối')));
          },
          '/trip': (context) => TripListScreen(),
          '/trip/search': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null
                ? const TripSearchScreen()
                : const LoginPromptScreen();
          },
          '/trip/detail/:id': (context) => TripDetailScreen(),
          '/seat': (context) => SeatListScreen(),
          '/seat/create': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null && authService.isAdmin()
                ? SeatCreateScreen()
                : const LoginPromptScreen();
          },
          '/seat/edit/:id': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            final id = ModalRoute.of(context)!.settings.arguments as String?;
            if (authService.currentUser != null && authService.isAdmin() && id != null && id.isNotEmpty) {
              return SeatEditScreen(id: id);
            }
            return const Scaffold(body: Center(child: Text('ID ghế không hợp lệ hoặc quyền truy cập bị từ chối')));
          },
          '/tickets': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return authService.currentUser != null
                ? const TicketScreen()
                : const LoginPromptScreen();
          },
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Không tìm thấy trang')),
            ),
          );
        },
        navigatorObservers: [
          RouteObserver(
            onNavigate: (routeName) async {
              if (_isValidRoute(routeName)) {
                final storage = FlutterSecureStorage();
                print('Saving route: $routeName');
                await storage.write(key: 'currentRoute', value: routeName);
              }
            },
          ),
        ],
      ),
    );
  }

  bool _isValidRoute(String? routeName) {
    if (routeName == null) return false;
    const validRoutes = [
      '/home',
      '/trip/search',
      '/tickets',
      '/auth/profile',
      '/trip',
      '/location',
      '/trip/detail/:id',
      '/admin',
      '/admin/seats',
      '/admin/tickets',
      '/admin/trips',
      '/admin/users',
    ];
    return validRoutes.contains(routeName) || routeName.startsWith('/trip/detail/');
  }
}

class RouteObserver extends NavigatorObserver {
  final Function(String) onNavigate;

  RouteObserver({required this.onNavigate});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name;
    if (routeName != null) {
      onNavigate(routeName);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final routeName = newRoute?.settings.name;
    if (routeName != null) {
      onNavigate(routeName);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = previousRoute?.settings.name;
    if (routeName != null) {
      onNavigate(routeName);
    }
  }
}