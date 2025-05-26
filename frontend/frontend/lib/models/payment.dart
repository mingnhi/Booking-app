class Payment {
  final String? id;
  final String ticketId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? paymentDate;
  final String? paypalPaymentId;
  final String? saleId;

  Payment({
    this.id,
    required this.ticketId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
    this.paypalPaymentId,
    this.saleId,
  });

  Map<String, dynamic> toJson() => {
    'ticket_id': ticketId,
    'amount': amount,
    'payment_method': paymentMethod,
    'payment_status': paymentStatus,
    'payment_date': paymentDate?.toIso8601String(),
    'paypal_payment_id': paypalPaymentId,
    'sale_id': saleId,
  };
  
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] ?? json['id'],
      ticketId: json['ticket_id'],
      amount: json['amount']?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'unknown',
      paymentStatus: json['payment_status'] ?? 'PENDING',
      paymentDate: json['payment_date'] != null 
          ? DateTime.parse(json['payment_date']) 
          : DateTime.now(),
      paypalPaymentId: json['paypal_payment_id'],
      saleId: json['sale_id'],
    );
  }
}
