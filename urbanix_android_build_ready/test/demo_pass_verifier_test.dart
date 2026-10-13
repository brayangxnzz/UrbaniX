import 'package:flutter_test/flutter_test.dart';
import 'package:urbanix_recovery/qr_demo_service.dart';
import 'package:urbanix_recovery/demo_pass_verifier.dart';

void main() {
  test('Verifica solo un pase DEMO vigente', () {
    final now = DateTime.utc(2026, 10, 12, 12);
    final pass = DemoPassService().issue(route: 'Metro', passengers: 2, now: now);
    expect(DemoPassVerifier().verify(pass.payload, now.add(const Duration(minutes: 1))).valid, true);
    expect(DemoPassVerifier().verify(pass.payload, now.add(const Duration(minutes: 15))).valid, false);
  });
  test('Rechaza entradas no-demo', () {
    expect(DemoPassVerifier().verify('abc', DateTime.utc(2026)).valid, false);
  });
}
