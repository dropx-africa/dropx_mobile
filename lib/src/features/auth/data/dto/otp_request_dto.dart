import 'package:json_annotation/json_annotation.dart';

part 'otp_request_dto.g.dart';

/// Request payload for the OTP request endpoint.
@JsonSerializable(createFactory: false)
class OtpRequestDto {
  @JsonKey(name: 'phone_e164')
  final String phoneE164;

  final String purpose;
  final String channel;

  const OtpRequestDto({
    required this.phoneE164,
    this.purpose = 'LOGIN',
    this.channel = 'sms',
  });

  Map<String, dynamic> toJson() => _$OtpRequestDtoToJson(this);
}
