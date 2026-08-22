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

/// Response for `GET /support/resolve/:support_id` — resolves a legacy
/// ticket id, support case id, or dispute id to its kind and app route,
/// without the caller having to guess by id prefix.
class SupportRecordSummary {
  final String recordId;
  final String recordType;
  final String title;
  final String status;
  final String? priority;
  final String route;

  const SupportRecordSummary({
    required this.recordId,
    required this.recordType,
    required this.title,
    required this.status,
    this.priority,
    required this.route,
  });

  factory SupportRecordSummary.fromJson(Map<String, dynamic> json) {
    return SupportRecordSummary(
      recordId: json['record_id'] as String? ?? '',
      recordType: json['record_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      priority: json['priority'] as String?,
      route: json['route'] as String? ?? '',
    );
  }
}
