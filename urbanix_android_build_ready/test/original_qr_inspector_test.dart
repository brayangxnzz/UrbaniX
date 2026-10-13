import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanix_recovery/original_qr_inspector.dart';

void main() {
  final inspector = OriginalQrInspector();
  test('rechaza entrada no Base64', () {
    expect(inspector.inspect('***').isBase64, false);
  });
  test('reconoce la forma documentada de un QR histórico', () {
    final simulatedBinary = List<int>.generate(384, (i) => i % 256);
    final sample = base64Encode(simulatedBinary);
    final result = inspector.inspect(sample);
    expect(result.isBase64, true);
    expect(result.textLength, 512);
    expect(result.decodedByteLength, 384);
    expect(result.matchesObservedSampleShape(), true);
    // NO comprueba autenticidad: los datos sintéticos pasan una prueba de forma.
  });
  test('un QR de otro tamaño no coincide con esa única muestra', () {
    expect(inspector.inspect(base64Encode([1, 2, 3])).matchesObservedSampleShape(), false);
  });
}
