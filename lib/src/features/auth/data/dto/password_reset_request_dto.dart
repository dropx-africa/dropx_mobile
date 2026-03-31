/// Request payload for /auth/password/reset/request
///
/// {
///   "email": "user@example.com",   // for email-based reset
///   "phone": "+2348010002001",      // for phone-based reset (not active yet)
///   "audience": "customer"
/// }
class PasswordResetRequestDto {
  final String? email;
  final String? phone;
  final String audience;

  const PasswordResetRequestDto({
    this.email,
    this.phone,
    this.audience = 'customer',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'audience': audience};
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    return map;
  }
}
