import 'package:json_annotation/json_annotation.dart';

enum VendorCategory {
  @JsonValue('food')
  food,
  @JsonValue('pharmacy')
  pharmacy,
  @JsonValue('parcel')
  parcel,
  @JsonValue('retail')
  retail,
  @JsonValue('other')
  other,
}
