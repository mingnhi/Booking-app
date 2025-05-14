class Location {
  final String id;
  final String location;
  // Các trường khác nếu có

  Location({
    required this.id,
    required this.location,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'] ?? '',
      location: json['location'] ?? '',
    );
  }
}
