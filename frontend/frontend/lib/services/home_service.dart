import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../models/location.dart';
import '../services/trip_service.dart';
import '../services/location_service.dart';
import 'package:flutter/material.dart';

class HomeService extends ChangeNotifier {
  bool isLoading = false;
  List<Trip> featuredTrips = [];
  List<Location> locations = [];
  String? errorMessage;

  Future<void> fetchHomeData(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final tripService = Provider.of<TripService>(context, listen: false);
      final locationService = Provider.of<LocationService>(context, listen: false);

      await tripService.fetchTrips();
      featuredTrips = tripService.trips.take(5).toList();

      await locationService.fetchLocations();
      locations = locationService.locations;
    } catch (e) {
      print('Error fetching home data: $e');
      errorMessage = e.toString();
      if (e.toString().contains('No access token found')) {
        // Điều hướng về màn hình đăng nhập nếu không có token
        Navigator.pushReplacementNamed(context, '/auth/login');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}