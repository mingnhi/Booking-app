import 'package:intl/intl.dart';

class Trip {
  final String id;
  final String vehicle_id;
  final String departure_location;
  final String arrival_location;
  final DateTime departure_time;
  final DateTime arrival_time;
  final double price;
  final double distance;
  final int totalSeats;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Trip({
    required this.id,
    required this.vehicle_id,
    required this.departure_location,
    required this.arrival_location,
    required this.departure_time,
    required this.arrival_time,
    required this.price,
    required this.distance,
    required this.totalSeats,
    this.createdAt,
    this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['_id'],
      vehicle_id: json['vehicle_id'],
      departure_location: json['departure_location'],
      arrival_location: json['arrival_location'],
      departure_time: DateTime.parse(json['departure_time']),
      arrival_time: DateTime.parse(json['arrival_time']),
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price'].toDouble(),
      distance:
          (json['distance'] is int)
              ? (json['distance'] as int).toDouble()
              : json['distance'].toDouble(),
      totalSeats: json['total_seats'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'vehicle_id': vehicle_id,
    'departure_location': departure_location,
    'arrival_location': arrival_location,
    'departure_time': departure_time.toIso8601String(),
    'arrival_time': arrival_time.toIso8601String(),
    'price': price,
    'distance': distance,
    'total_seats': totalSeats,
  };
}
