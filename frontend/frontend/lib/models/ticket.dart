class Ticket {
  final String id;
  final String user_id;
  final String trip_id;
  final String seat_id;
  final String ticket_status;
  final DateTime booked_at;
  final DateTime? updated_at;

  Ticket({
    required this.id,
    required this.user_id,
    required this.trip_id,
    required this.seat_id,
    required this.ticket_status,
    required this.booked_at,
    this.updated_at,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'],
      user_id: json['user_id'],
      trip_id: json['trip_id'],
      seat_id: json['seat_id'],
      ticket_status: json['ticket_status'],
      booked_at: DateTime.parse(json['booked_at']),
      updated_at: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': user_id,
    'trip_id': trip_id,
    'seat_id': seat_id,
    'ticket_status': ticket_status,
    'booked_at': booked_at.toIso8601String(),
    'updated_at': updated_at?.toIso8601String(),
  };
}