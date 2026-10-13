import 'dart:convert';

/// Inspecciona únicamente la envoltura de mensajes proporcionados voluntariamente.
/// NO descifra, autentica, firma, canjea ni genera boletos de transporte.
class ProtocolReport {
  final int segments;
  final List<int> decodedByteLengths;
  final Map<String, String> publicHeaderFields;
  final bool structurallyBase64;
  final List<String> warnings;

  const ProtocolReport({required this.segments, required this.decodedByteLengths,
    required this.publicHeaderFields, required this.structurallyBase64,
    required this.warnings});

  String get kind => segments == 4 && publicHeaderFields.containsKey('v')
      ? 'Posible entrega del bot (4 segmentos)'
      : segments == 2 ? 'Posible solicitud de compra (2 segmentos)'
      : 'Formato no reconocido';
}

class ProtocolInspector {
  static const maxInputLength = 20000;
  static const allowedHeaderKeys = <String>{'v', 'installation_id', 'key_fingerprint', 'operation_id'};

  ProtocolReport inspect(String input) {
    final s = input.trim();
    if (s.isEmpty || s.length > maxInputLength) {
      throw const FormatException('Texto vacío o demasiado largo');
    }
    // El punto final presente en algunos mensajes copiados es separador final,
    // no un bloque adicional. No alteramos el texto original, solo lo analizamos.
    final segments = s.endsWith('.') ? s.substring(0, s.length - 1).split('.') : s.split('.');
    final lengths = <int>[];
    final warnings = <String>[];
    var valid = true;
    final decoded = <List<int>>[];
    for (final part in segments) {
      try {
        if (part.isEmpty || !RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(part)) {
          throw const FormatException('Segmento inválido');
        }
        final bytes = base64.decode(base64.normalize(part));
        lengths.add(bytes.length);
        decoded.add(bytes);
      } catch (_) {
        valid = false;
        lengths.add(0);
        decoded.add(const []);
      }
    }
    final header = <String, String>{};
    // Solo se interpreta el primer bloque de una posible entrega de cuatro bloques.
    if (segments.length == 4 && valid) {
      try {
        final obj = jsonDecode(utf8.decode(decoded.first));
        if (obj is Map<String, dynamic>) {
          for (final k in allowedHeaderKeys) {
            if (obj.containsKey(k)) header[k] = obj[k].toString();
          }
        }
      } catch (_) {
        warnings.add('El encabezado no contiene JSON legible.');
      }
    }
    if (!valid) warnings.add('Hay segmentos que no son Base64 válido.');
    warnings.add('Una estructura reconocible no demuestra autenticidad ni validez para viajar.');
    return ProtocolReport(segments: segments.length,
      decodedByteLengths: lengths, publicHeaderFields: header,
      structurallyBase64: valid, warnings: warnings);
  }
}
