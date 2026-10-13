import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Formato de PRUEBAS INTERNO. No compatible con lectores oficiales.
class DemoPass {
  final String route;
  final int passengers;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String payload;

  const DemoPass({required this.route, required this.passengers,
    required this.issuedAt, required this.expiresAt, required this.payload});
}

class DemoPassService {
  static const supportedRoutes = ['Metro', 'Transmetro', 'Ruta Integrada', 'Muevo León'];
  static const validity = Duration(minutes: 15);

  DemoPass issue({required String route, required int passengers, required DateTime now}) {
    if (!supportedRoutes.contains(route)) {
      throw ArgumentError.value(route, 'route', 'Transporte no reconocido');
    }
    if (passengers < 1 || passengers > 9) {
      throw RangeError.range(passengers, 1, 9, 'passengers');
    }
    final expires = now.add(validity);
    final data = <String, dynamic>{
      'format': 'URBANIX_DEMO_NOT_VALID_FOR_TRAVEL',
      'version': 1,
      'route': route,
      'passengers': passengers,
      'issued_at': now.toUtc().toIso8601String(),
      'expires_at': expires.toUtc().toIso8601String(),
    };
    // Identificador solo de diagnóstico; NO es una firma ni una credencial.
    final fingerprint = sha256.convert(utf8.encode(jsonEncode(data))).toString().substring(0, 16);
    data['diagnostic_id'] = fingerprint;
    return DemoPass(route: route, passengers: passengers, issuedAt: now,
      expiresAt: expires, payload: jsonEncode(data));
  }

  bool isActive(DemoPass pass, DateTime now) => now.isBefore(pass.expiresAt);
}
