import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_quote_request.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_quote_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/create_parcel_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/create_parcel_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/place_parcel_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/place_parcel_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_payment_initialize_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_payment_initialize_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_detail_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_tracking_live_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/verify_parcel_paystack_payment_request.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/verify_parcel_paystack_payment_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/verify_parcel_recipient_confirmation_response.dart';

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

  /// Verify a Paystack browser return for a parcel payment. Must be called
  /// before treating a parcel as paid — the redirect URL alone is not proof
  /// of payment.
  Future<VerifyParcelPaystackPaymentData> verifyPaystackPayment(
    VerifyParcelPaystackPaymentRequest request,
  );

  Future<ParcelDetail> getParcel(String parcelId);

  /// GET /parcels — returns the user's parcel list.
  Future<List<ParcelDetail>> getParcels();

  /// POST /parcels/:id/payment-link — returns a shareable token/URL.
  Future<String> generatePaymentLink(String parcelId);

  /// GET /parcels/:id/tracking-live — live rider position and ETA.
  Future<ParcelTrackingLiveData> getParcelTrackingLive(String parcelId);

  /// POST /parcels/:id/recipient-confirmation/verify — confirms handoff
  /// using the code the recipient shares with the customer during delivery.
  Future<VerifyParcelRecipientConfirmationData> verifyRecipientConfirmation(
    String parcelId,
    String confirmationCode,
  );
}
