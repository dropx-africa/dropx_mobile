import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_quote_request.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_quote_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/create_parcel_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/create_parcel_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/place_parcel_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/place_parcel_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_payment_initialize_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_payment_initialize_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_detail_response.dart';

abstract class ParcelRepository {
  Future<ParcelQuoteData> getQuote(ParcelQuoteRequest request);

  Future<CreateParcelData> createParcel(CreateParcelDto dto);

  Future<PlaceParcelData> placeParcel(
    String parcelId,
    PlaceParcelDto dto,
  );

  Future<ParcelPaymentInitializeData> initializePayment(
    String parcelId,
    ParcelPaymentInitializeDto dto,
  );

  Future<ParcelDetail> getParcel(String parcelId);

  /// GET /parcels — returns the user's parcel list.
  Future<List<ParcelDetail>> getParcels();

  /// POST /parcels/:id/payment-link — returns a shareable token/URL.
  Future<String> generatePaymentLink(String parcelId);
}
