// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost_breakdown.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CostBreakdown _$CostBreakdownFromJson(Map<String, dynamic> json) =>
    CostBreakdown(
      currency: json['currency'] as String?,
      subtotalKobo: json['subtotal_kobo'] == null
          ? 0
          : _parseInt(json['subtotal_kobo']),
      deliveryFeeKobo: json['delivery_fee_kobo'] == null
          ? 0
          : _parseInt(json['delivery_fee_kobo']),
      serviceFeeKobo: json['service_fee_kobo'] == null
          ? 0
          : _parseInt(json['service_fee_kobo']),
      insuranceFeeKobo: json['insurance_fee_kobo'] == null
          ? 0
          : _parseInt(json['insurance_fee_kobo']),
      taxKobo: json['tax_kobo'] == null ? 0 : _parseInt(json['tax_kobo']),
      totalKobo: json['total_kobo'] == null ? 0 : _parseInt(json['total_kobo']),
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map(
                (e) => CostBreakdownLine.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CostBreakdownToJson(CostBreakdown instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'subtotal_kobo': instance.subtotalKobo,
      'delivery_fee_kobo': instance.deliveryFeeKobo,
      'service_fee_kobo': instance.serviceFeeKobo,
      'insurance_fee_kobo': instance.insuranceFeeKobo,
      'tax_kobo': instance.taxKobo,
      'total_kobo': instance.totalKobo,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };

CostBreakdownLine _$CostBreakdownLineFromJson(Map<String, dynamic> json) =>
    CostBreakdownLine(
      key: json['key'] as String,
      label: json['label'] as String,
      amountKobo: _parseInt(json['amount_kobo']),
      type: json['type'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      emphasis: json['emphasis'] as bool?,
    );

Map<String, dynamic> _$CostBreakdownLineToJson(CostBreakdownLine instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'amount_kobo': instance.amountKobo,
      'type': instance.type,
      'sort_order': instance.sortOrder,
      'emphasis': instance.emphasis,
    };
