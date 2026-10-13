import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanix_recovery/qr_demo_service.dart';

void main() {
  final service = DemoPassService();
  final now = DateTime.utc(2026, 10, 12, 12);
  test('Emite un JSON explícitamente DEMO y con expiración a 15 minutos', () {
    final pass = service.issue(route: 'Metro', passengers: 2, now: now);
    final decoded = jsonDecode(pass.payload) as Map<String, dynamic>;
    expect(decoded['format'], 'URBANIX_DEMO_NOT_VALID_FOR_TRAVEL');
    expect(decoded['passengers'], 2);
    expect(pass.expiresAt.difference(pass.issuedAt), const Duration(minutes: 15));
    expect(service.isActive(pass, now.add(const Duration(minutes: 14))), isTrue);
    expect(service.isActive(pass, now.add(const Duration(minutes: 15))), isFalse);
  });
  test('Rechaza pasajeros fuera de 1–9', () {
    expect(() => service.issue(route: 'Metro', passengers: 0, now: now), throwsRangeError);
    expect(() => service.issue(route: 'Metro', passengers: 10, now: now), throwsRangeError);
  });
  test('Rechaza rutas no contempladas', () {
    expect(() => service.issue(route: 'Desconocido', passengers: 1, now: now), throwsArgumentError);
  });
}
