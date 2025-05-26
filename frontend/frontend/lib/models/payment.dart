class Payment {
  final String? id;
  final String ticketId;
  final double amount;
  final String? orderId;
  final String? captureId;
  final String? paypalPaymentId;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? paymentDate;

  Payment({
    this.id,
    required this.ticketId,
    required this.amount,
    this.orderId,
    this.captureId,
    this.paypalPaymentId,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'],
      ticketId:
      json['ticket_id'] is Map
          ? json['ticket_id']['_id']
          : json['ticket_id'],
      amount: (json['amount'] as num).toDouble(),
      orderId: json['order_id'],
      captureId: json['capture_id'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      paymentDate:
      json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ticket_id': ticketId,
    'amount': amount,
    'sale_id': orderId,
    'capture_id': captureId,
    'payment_method': paymentMethod,
    'payment_status': paymentStatus,
    'payment_date': paymentDate?.toIso8601String(),
  };

  @override
  String toString() {
    return 'Payment{id: $id, ticketId: $ticketId, paypalPaymentId: $paypalPaymentId, orderId: $orderId, amount: $amount, status: $paymentStatus}';
  }
}
