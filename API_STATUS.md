# DropX Mobile — API Endpoints Status

> Generated: 2026-03-25
> Source: `lib/src/core/network/api_endpoints.dart` + all `remote_*_repository.dart` files

---

## Summary

| Category | Count |
|---|---|
| Total endpoints defined | ~54 |
| Fully implemented & called | 32 (~59%) |
| Defined but never called | 8 |
| Features with UI but no backend | 2 (Group Orders, Wallet) |
| Stubbed TODOs | 5 |
| Response ↔ UI mismatches | 4 (see Customer Feedback section) |

---

## Auth Endpoints — `/auth/*`, `/me/*`

| Method | Path | Status |
|---|---|---|
| POST | `/auth/login` | ✅ Implemented |
| POST | `/auth/register` | ✅ Implemented |
| POST | `/auth/otp/request` | ✅ Implemented |
| POST | `/auth/otp/resend` | ✅ Implemented |
| POST | `/auth/otp/verify` | ✅ Implemented |
| POST | `/auth/refresh` | ✅ Implemented |
| POST | `/auth/logout` | ✅ Implemented |
| GET | `/me/profile` | ✅ Implemented |
| PATCH | `/me/profile` | ✅ Implemented |
| GET | `/me/preferences` | ✅ Implemented |
| PATCH | `/me/preferences` | ✅ Implemented |
| GET | `/me/addresses` | ✅ Implemented |
| POST | `/me/addresses` | ✅ Implemented |

---

## Order Endpoints — `/orders/*`

| Method | Path | Status |
|---|---|---|
| GET | `/orders` | ✅ Implemented |
| POST | `/orders` | ✅ Implemented |
| GET | `/orders/{id}` | ✅ Implemented |
| POST | `/orders/{id}/place` | ✅ Implemented |
| POST | `/orders/{id}/payment-link` | ✅ Implemented |
| POST | `/orders/estimate` | ✅ Implemented |
| GET | `/orders/{id}/tracking-live` | ✅ Implemented |
| GET | `/orders/{id}/timeline` | ✅ Implemented |
| POST | `/orders/{id}/cancel` | ✅ Implemented |
| POST | `/orders/{id}/dispute` | ✅ Implemented |
| POST | `/orders/{id}/reviews` | ✅ Implemented |
| GET | `/orders/{id}/reviews/me` | ✅ Implemented |
| GET | `/orders/tracking` | ❌ Defined, never called — `/orders/{id}/tracking-live` is used instead |

---

## Vendor Endpoints — `/vendors/*`, `/stores/*`

| Method | Path | Status |
|---|---|---|
| GET | `/vendors` | ✅ Implemented |
| GET | `/vendors/{id}` | ✅ Implemented |
| GET | `/stores/{vendorId}/catalog` | ✅ Implemented |
| GET | `/vendors/{vendorId}/menu` | ❌ Defined, never called — `/stores/{vendorId}/catalog` is used instead |

---

## Payment Endpoints — `/payments/*`, `/pay-links/*`

| Method | Path | Status |
|---|---|---|
| POST | `/payments/initialize` | ✅ Implemented |
| GET | `/pay-links/{token}` | ✅ Implemented |
| POST | `/pay-links/{token}/initialize` | ✅ Implemented |

---

## Location Endpoints — `/maps/*`, `/locations/*`

| Method | Path | Status |
|---|---|---|
| GET | `/maps/geocode` | ✅ Implemented |
| GET | `/locations/search` | ❌ Marked legacy, never called — `/maps/geocode` is used instead |

> Note: Google Maps API is also called directly (PlacesService) for autocomplete and reverse geocoding.

---

## Notification Endpoints — `/me/notifications/*`

| Method | Path | Status |
|---|---|---|
| GET | `/me/notifications` | ✅ Implemented |
| PATCH | `/me/notifications/read-all` | ✅ Implemented |
| PATCH | `/me/notifications/{id}/read` | ✅ Implemented |

---

## Social Endpoints — `/social/*`

| Method | Path | Status |
|---|---|---|
| POST | `/social/contacts/sync` | ✅ Implemented |
| GET | `/social/feed` | ✅ Implemented |
| GET | `/social/preferences` | ❌ Defined, never called — no repository method exists |

---

## Group Order Endpoints — `/groups/*`

| Method | Path | Status |
|---|---|---|
| GET | `/groups` | ❌ Defined, never called — no repository exists |
| GET | `/groups/{id}` | ❌ Defined, never called — no repository exists |
| POST | `/groups/{id}/poll` | ❌ Defined, never called — no repository exists |

> UI screens exist (`group_screen.dart`, `poll_creation_screen.dart`, `poll_voting_screen.dart`) but all state is local only. Share button has empty `onPressed: () {}`.

---

## Home & Search Endpoints

| Method | Path | Status |
|---|---|---|
| GET | `/home/feed` | ✅ Implemented |
| GET | `/search` | ✅ Implemented |

---

## Support Endpoints

| Method | Path | Status |
|---|---|---|
| POST | `/support/tickets` | ✅ Implemented |
| GET | `/support/tickets/{id}` | ✅ Implemented |

---

## Cart Endpoint

| Method | Path | Status |
|---|---|---|
| GET/POST | `/cart` | ❌ Defined, never called — cart is entirely client-side (Riverpod) |

---

## Incomplete / Stubbed Code

### 1. Token Storage — `remote_auth_repository.dart`
```dart
Future<bool> isAuthenticated() {
  // TODO: Check Token Storage
  return false; // always returns false
}

Future<String?> getToken() {
  // TODO: Get from Storage
  return null; // always returns null
}
```
**Impact:** These are likely superseded by a proper token storage mechanism elsewhere (e.g., SecureStorage or SharedPreferences via a provider), but the stubs remain.

### 2. Preferences Screen — `preferences_screen.dart`
```dart
// TODO: Implement language picker   (line ~45)
// TODO: Implement currency picker   (line ~53)
```
**Impact:** Language and currency selection in the profile preferences screen are not functional.

### 3. Onboarding — `onboarding_screen.dart`
```dart
// TODO: Navigate to help/support   (line ~56)
```
**Impact:** Help/support navigation from the onboarding screen is not connected.

---

## What the UI Needs but the Response Doesn't Provide

| Endpoint | Missing from response |
|---|---|
| `GET /home/feed` | `image_url` on each feed item |
| `GET /stores/{vendorId}/catalog` | `image_url` (unreliable), `logo_url` (commented out in UI) on the `store` object |
| Wallet | Entire feature — no endpoints for balance, transactions, or top-up |
| `GET /orders/{id}/tracking-live` | `rider.phone`, `rider.photo_url`, `rider.vehicle`, `rider.plate_number`, `rider.rating` — all hardcoded in UI right now |

---

## Features Not Yet Functional

| Feature | Files | Blocker |
|---|---|---|
| **Wallet** | `lib/src/features/wallet/presentation/wallet_screen.dart` | No endpoints defined. Balance hardcoded to ₦0.00. Top-up is "coming soon". Transaction list uses orders as a workaround. |
| **Group Orders** | `lib/src/features/group/presentation/` | No `RemoteGroupRepository`. Endpoints defined, never called. UI state is local only. |
| **Rider Details on Tracking** | tracking screen `_buildRiderInfo()` | Response `rider` object missing `phone`, `photo_url`, `vehicle`, `plate_number`, `rating`. All hardcoded in UI. |
| **Home Feed Images** | `lib/src/features/home/data/feed_item.dart` | `FeedItem` model has no `image_url` field. Gray placeholder shown always. |
| **Vendor Banner Image** | `VendorMenuScreen` store header | `image_url` missing/null from response falls back to local asset. `logo_url` commented out. |
| **Preferences Pickers** | `lib/src/features/profile/presentation/preferences_screen.dart` | Language + currency pickers are TODO stubs. |
| **Social Preferences** | — | `GET /social/preferences` endpoint defined but never called and no UI for it. |
| **Onboarding Help Link** | `lib/src/features/onboarding/presentation/onboarding_screen.dart` | Navigation to support not wired up. |

---

## Key Source Files

| File | Purpose |
|---|---|
| `lib/src/core/network/api_endpoints.dart` | All endpoint path constants |
| `lib/src/core/network/api_client.dart` | HTTP client (GET/POST/PUT/PATCH/DELETE, token refresh, error handling) |
| `lib/src/features/auth/data/remote_auth_repository.dart` | Auth + profile API calls |
| `lib/src/features/order/data/remote_order_repository.dart` | Order lifecycle API calls |
| `lib/src/features/vendor/data/remote_vendor_repository.dart` | Vendor + catalog API calls |
| `lib/src/features/location/data/remote_location_repository.dart` | Geocoding API calls |
| `lib/src/features/location/data/remote_address_repository.dart` | Saved addresses API calls |
| `lib/src/features/profile/data/remote_notification_repository.dart` | Notification API calls |
| `lib/src/features/profile/data/remote_social_repository.dart` | Social feed + contacts sync |
| `lib/src/features/support/data/remote_support_repository.dart` | Support tickets API calls |
| `lib/src/features/paylink/data/remote_pay_link_repository.dart` | Pay-link API calls |
| `lib/src/features/cart/providers/cart_provider.dart` | Client-side cart (no API) |
| `lib/src/features/group/presentation/` | Group orders UI (no API backing) |
