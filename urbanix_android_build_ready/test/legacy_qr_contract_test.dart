import 'package:flutter_test/flutter_test.dart';
import 'package:urbanix_recovery/legacy_qr_contract.dart';

void main() {
  test('No confundir el generador de pruebas con compatibilidad V2', () async {
    final result = await UnavailableLegacyQrEmitter().issue(LegacyQrRequest(
      transport: 'Metro', passengers: 1,
      issuedAt: DateTime.utc(2026, 10, 12), installationId: 'test',
    ));
    expect(result.compatible, false);
    expect(result.payload, isNull);
  });
}
