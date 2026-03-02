import 'package:json_annotation/json_annotation.dart';

part 'ticket_dto.g.dart';

@JsonSerializable(createFactory: false)
class CreateTicketDto {
  final String category;
  final String subject;
  final String message;
  final String priority;

  const CreateTicketDto({
    required this.category,
    required this.subject,
    required this.message,
    required this.priority,
  });

  Map<String, dynamic> toJson() => _$CreateTicketDtoToJson(this);
}

@JsonSerializable()
class TicketResponseData {
  @JsonKey(name: 'ticket_id')
  final String ticketId;

  @JsonKey(name: 'user_id')
  final String userId;

  final String category;
  final String subject;
  final String message;
  final String status;
  final String priority;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const TicketResponseData({
    required this.ticketId,
    required this.userId,
    required this.category,
    required this.subject,
    required this.message,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketResponseData.fromJson(Map<String, dynamic> json) =>
      _$TicketResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$TicketResponseDataToJson(this);
}
