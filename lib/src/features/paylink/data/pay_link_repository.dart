import 'package:dropx_mobile/src/features/paylink/data/dto/initialize_pay_link_dto.dart';
import 'package:dropx_mobile/src/features/paylink/data/dto/initialize_pay_link_response.dart';
import 'package:dropx_mobile/src/features/paylink/data/dto/pay_link_details_response.dart';

/// Abstract repository interface for payment links.
abstract class PayLinkRepository {
  /// Fetch details of a payment link using its token.
  Future<PayLinkDetailsResponse> getPayLinkDetails(String token);

  /// Initialize payment for a payment link (returns Paystack checkout URL).
  Future<InitializePayLinkResponse> initializePayLink(
    String token,
    InitializePayLinkDto dto,
  );
}
