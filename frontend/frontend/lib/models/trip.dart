import 'package:intl/intl.dart';

class Trip {
  final String id;
  final String locationId;
  final String departureLocation;
  final String arrivalLocation;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final String busType;
  final int totalSeats;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Trip({
    required this.id,
    required this.locationId,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.busType,
    required this.totalSeats,
    this.createdAt,
    this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['_id'],
      locationId: json['location_id'],
      departureLocation: json['departure_location'],
      arrivalLocation: json['arrival_location'],
      departureTime: DateTime.parse(json['departure_time']),
      arrivalTime: DateTime.parse(json['arrival_time']),
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'].toDouble(),
      busType: json['bus_type'],
      totalSeats: json['total_seats'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'location_id': locationId,
    'departure_location': departureLocation,
    'arrival_location': arrivalLocation,
    'departure_time': departureTime.toIso8601String(),
    'arrival_time': arrivalTime.toIso8601String(),
    'price': price,
    'bus_type': busType,
    'total_seats': totalSeats,
  };
}