class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;
  final String? refreshToken;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      role: json['role'],
      refreshToken: json['refresh_token'],
    );
  }
}