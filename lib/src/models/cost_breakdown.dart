import 'package:json_annotation/json_annotation.dart';

part 'cost_breakdown.g.dart';

int _parseInt(dynamic v) {
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  if (v is num) return v.toInt();
  return 0;
}

@JsonSerializable(explicitToJson: true)
class CostBreakdown {
  final String? currency;

  @JsonKey(name: 'subtotal_kobo', fromJson: _parseInt)
  final int subtotalKobo;

  @JsonKey(name: 'delivery_fee_kobo', fromJson: _parseInt)
  final int deliveryFeeKobo;

  @JsonKey(name: 'service_fee_kobo', fromJson: _parseInt)
  final int serviceFeeKobo;

  @JsonKey(name: 'insurance_fee_kobo', fromJson: _parseInt)
  final int insuranceFeeKobo;

  @JsonKey(name: 'tax_kobo', fromJson: _parseInt)
  final int taxKobo;

  @JsonKey(name: 'total_kobo', fromJson: _parseInt)
  final int totalKobo;

  final List<CostBreakdownLine> lines;

  const CostBreakdown({
    this.currency,
    this.subtotalKobo = 0,
    this.deliveryFeeKobo = 0,
    this.serviceFeeKobo = 0,
    this.insuranceFeeKobo = 0,
    this.taxKobo = 0,
    this.totalKobo = 0,
    this.lines = const [],
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) =>
      _$CostBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$CostBreakdownToJson(this);
}

@JsonSerializable()
class CostBreakdownLine {
  final String key;
  final String label;

  @JsonKey(name: 'amount_kobo', fromJson: _parseInt)
  final int amountKobo;

  final String type;

  @JsonKey(name: 'sort_order')
  final int sortOrder;

  final bool? emphasis;

  const CostBreakdownLine({
    required this.key,
    required this.label,
    required this.amountKobo,
    required this.type,
    required this.sortOrder,
    this.emphasis,
  });

  factory CostBreakdownLine.fromJson(Map<String, dynamic> json) =>
      _$CostBreakdownLineFromJson(json);

  Map<String, dynamic> toJson() => _$CostBreakdownLineToJson(this);
}
