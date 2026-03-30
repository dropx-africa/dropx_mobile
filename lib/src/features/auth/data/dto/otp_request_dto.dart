/// Request payload for the OTP request endpoint.
///
/// Matches the actual API shape:
/// {
///   "email": "user@example.com",      // optional
///   "phone_e164": "+2348010002001",    // optional, but at least one required
///   "purpose": "REGISTER",
///   "channel": "sms"
/// }
class OtpRequestDto {
  final String? email;
  final String? phoneE164;
  final String purpose;
  final String channel;

  const OtpRequestDto({
    this.email,
    this.phoneE164,
    this.purpose = 'REGISTER',
    this.channel = 'sms',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'purpose': purpose,
      'channel': channel,
    };
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (phoneE164 != null && phoneE164!.isNotEmpty) {
      map['phone_e164'] = phoneE164;
    }
    return map;
  }
}
