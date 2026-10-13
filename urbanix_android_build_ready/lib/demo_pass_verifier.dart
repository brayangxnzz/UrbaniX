import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Verificador SOLO para códigos URBANIX_DEMO_NOT_VALID_FOR_TRAVEL.
/// El hash de diagnóstico no es una firma criptográfica.
class DemoVerification {
  final bool valid;
  final String reason;
  const DemoVerification(this.valid, this.reason);
}

class DemoPassVerifier {
  DemoVerification verify(String payload, DateTime now) {
    try {
      final value = jsonDecode(payload);
      if (value is! Map<String, dynamic> ||
          value['format'] != 'URBANIX_DEMO_NOT_VALID_FOR_TRAVEL' ||
          value['version'] != 1) {
        return const DemoVerification(false, 'No es un QR de demostración Urbanix.');
      }
      final route = value['route'];
      final passengers = value['passengers'];
      final issueString = value['issued_at'];
      final expiresString = value['expires_at'];
      if (route is! String || !const ['Metro', 'Transmetro', 'Ruta Integrada', 'Muevo León'].contains(route) ||
          passengers is! int || passengers < 1 || passengers > 9 ||
          issueString is! String || expiresString is! String) {
        return const DemoVerification(false, 'Campos del pase de demostración inválidos.');
      }
      final issued = DateTime.parse(issueString).toUtc();
      final expires = DateTime.parse(expiresString).toUtc();
      if (expires.difference(issued) != const Duration(minutes: 15)) {
        return const DemoVerification(false, 'Duración incorrecta.');
      }
      final data = Map<String, dynamic>.from(value)..remove('diagnostic_id');
      final expected = sha256.convert(utf8.encode(jsonEncode(data))).toString().substring(0, 16);
      if (value['diagnostic_id'] != expected) {
        return const DemoVerification(false, 'El contenido del QR de prueba cambió.');
      }
      if (!now.toUtc().isBefore(expires)) {
        return const DemoVerification(false, 'El QR de prueba venció.');
      }
      return const DemoVerification(true, 'Estructura correcta para el simulador (no es boleto oficial).');
    } catch (_) {
      return const DemoVerification(false, 'No se pudo leer el QR de prueba.');
    }
  }
}
