import 'package:dropx_mobile/src/features/cart/data/dto/cart_dto.dart';

abstract class CartRepository {
  Future<ServerCartData> getCart();
  Future<void> syncCart(CartSyncDto dto);
  Future<void> clearCart();
}
