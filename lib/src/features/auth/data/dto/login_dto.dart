/// Request payload for the login endpoint.
///
/// Supports login via email OR phone_e164, both combined with a password.
class LoginDto {
  final String? email;

  final String? phoneE164;

  final String password;

  const LoginDto({this.email, this.phoneE164, required this.password})
      : assert(
          (email != null && email != '') ||
              (phoneE164 != null && phoneE164 != ''),
          'Either email or phoneE164 must be provided',
        );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'password': password};
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (phoneE164 != null && phoneE164!.isNotEmpty) {
      map['phone_e164'] = phoneE164;
    }
    return map;
  }
}
