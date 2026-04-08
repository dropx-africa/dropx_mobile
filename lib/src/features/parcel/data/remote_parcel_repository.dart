import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/parcel/data/parcel_repository.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_quote_request.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_quote_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/create_parcel_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/create_parcel_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/place_parcel_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/place_parcel_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_payment_initialize_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_payment_initialize_response.dart';

class RemoteParcelRepository implements ParcelRepository {
  final ApiClient _apiClient;

  RemoteParcelRepository(this._apiClient);

  @override
  Future<ParcelQuoteData> getQuote(ParcelQuoteRequest request) async {
    final body = request.toJson();
    debugPrint('🟡 [PARCEL-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.parcelsQuote}');
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<ParcelQuoteData>(
      ApiEndpoints.parcelsQuote,
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => ParcelQuoteData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint('✅ [PARCEL-API] quote → id=${response.data.quoteId}, total=${response.data.feeBreakdown.totalKobo}');
    return response.data;
  }

  @override
  Future<CreateParcelData> createParcel(CreateParcelDto dto) async {
    final body = dto.toJson();
    debugPrint('🟡 [PARCEL-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.parcels}');
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<CreateParcelData>(
      ApiEndpoints.parcels,
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => CreateParcelData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint('✅ [PARCEL-API] created → parcelId=${response.data.parcelId}');
    return response.data;
  }

  @override
  Future<PlaceParcelData> placeParcel(String parcelId, PlaceParcelDto dto) async {
    final body = dto.toJson();
    debugPrint('🟡 [PARCEL-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.parcelPlace(parcelId)}');
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<PlaceParcelData>(
      ApiEndpoints.parcelPlace(parcelId),
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => PlaceParcelData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint('✅ [PARCEL-API] placed → state=${response.data.state}');
    return response.data;
  }

  @override
  Future<ParcelPaymentInitializeData> initializePayment(
    String parcelId,
    ParcelPaymentInitializeDto dto,
  ) async {
    final body = dto.toJson();
    debugPrint('🟡 [PARCEL-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.parcelPaymentInitialize(parcelId)}');
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<ParcelPaymentInitializeData>(
      ApiEndpoints.parcelPaymentInitialize(parcelId),
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          ParcelPaymentInitializeData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint('✅ [PARCEL-API] payment init → ref=${response.data.reference}');
    return response.data;
  }
}
