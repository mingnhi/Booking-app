class Location {
  final String id;
  final String location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Location({required this.id, required this.location, this.createdAt, this.updatedAt});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'],
      location: json['location'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'location': location,
  };
}