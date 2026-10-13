import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Analizador no invasivo para comparar QR históricos de Urbanix V2.
/// No autentica, no descifra, no emite pases ni confirma validez del boleto.
class OriginalQrInspection {
  final bool isBase64;
  final int textLength;
  final int decodedByteLength;
  final String? decodedSha256;
  final String explanation;
  const OriginalQrInspection({required this.isBase64,
      required this.textLength, required this.decodedByteLength,
      required this.decodedSha256, required this.explanation});

  bool matchesObservedSampleShape() => isBase64 && textLength == 512 && decodedByteLength == 384;
}

class OriginalQrInspector {
  OriginalQrInspection inspect(String qrText) {
    final text = qrText.trim();
    if (text.isEmpty || text.length > 16384 ||
        !RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(text)) {
      return OriginalQrInspection(isBase64: false,
        textLength: text.length, decodedByteLength: 0, decodedSha256: null,
        explanation: 'El texto no tiene formato Base64 estándar válido.');
    }
    try {
      final data = base64.decode(text);
      return OriginalQrInspection(isBase64: true,
        textLength: text.length, decodedByteLength: data.length,
        decodedSha256: sha256.convert(data).toString(),
        explanation: 'Solo se comprobó la codificación y longitud; '
          'no se ha comprobado autenticidad o compatibilidad V2.');
    } on FormatException {
      return OriginalQrInspection(isBase64: false, textLength: text.length,
        decodedByteLength: 0, decodedSha256: null,
        explanation: 'Base64 estructuralmente inválido.');
    }
  }
}
