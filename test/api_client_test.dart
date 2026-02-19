import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiClient Tests', () {
    test('Singleton check', () {
      final client1 = ApiClient();
      final client2 = ApiClient();
      expect(client1, same(client2));
    });

    test('ApiEndpoints structure', () {
      expect(ApiEndpoints.baseUrl, contains('api-production'));
      expect(ApiEndpoints.login, '/auth/login');
    });

    test('setAuthToken updates internal state (indirect verification)', () {
      final client = ApiClient();
      client.setAuthToken('test-token');
      // in a real integration test we would verify the header is sent.
    });

    test('traceHeaders returns idempotency and trace id', () {
      final headers = ApiClient.traceHeaders();
      expect(headers, containsPair('Idempotency-Key', isA<String>()));
      expect(headers, containsPair('x-trace-id', isA<String>()));
      expect(headers['Idempotency-Key']!.length, greaterThan(0));
      expect(headers['x-trace-id']!.length, greaterThan(0));
    });

    test('traceHeaders generates unique ids per call', () {
      final h1 = ApiClient.traceHeaders();
      final h2 = ApiClient.traceHeaders();
      expect(h1['Idempotency-Key'], isNot(equals(h2['Idempotency-Key'])));
      expect(h1['x-trace-id'], isNot(equals(h2['x-trace-id'])));
    });

    test('Exception types', () {
      const authError = UnauthorizedException();
      expect(authError.statusCode, 401);

      const notFound = NotFoundException();
      expect(notFound.statusCode, 404);
    });
  });
}
