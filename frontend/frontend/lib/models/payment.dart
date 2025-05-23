class Payment {
  final String? id;
  final String ticketId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? paymentDate;

  Payment({
    this.id,
    required this.ticketId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
  });

  Map<String, dynamic> toJson()=>{
    'ticket_id': ticketId,
    'amount': amount,
    'payment_method': paymentMethod,
    'payment_status': paymentStatus,
    'payment_date': paymentDate?.toIso8601String(),

  };
}
