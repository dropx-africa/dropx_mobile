// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateTicketDtoToJson(CreateTicketDto instance) =>
    <String, dynamic>{
      'category': instance.category,
      'subject': instance.subject,
      'message': instance.message,
      'priority': instance.priority,
    };

TicketResponseData _$TicketResponseDataFromJson(Map<String, dynamic> json) =>
    TicketResponseData(
      ticketId: json['ticket_id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TicketResponseDataToJson(TicketResponseData instance) =>
    <String, dynamic>{
      'ticket_id': instance.ticketId,
      'user_id': instance.userId,
      'category': instance.category,
      'subject': instance.subject,
      'message': instance.message,
      'status': instance.status,
      'priority': instance.priority,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
