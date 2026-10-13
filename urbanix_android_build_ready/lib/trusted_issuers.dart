import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Registro explícito de claves públicas autorizado por el administrador.
/// No debe derivarse de códigos QR recibidos.
class TrustedIssuers {
  static const _key = 'urbanix_v3_trusted_issuers';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  Future<bool> register(String value) async {
    final normalized = value.trim();
    try {
      final decoded = base64Url.decode(base64Url.normalize(normalized));
      if (decoded.length != 32 ||
          base64UrlEncode(decoded).replaceAll('=', '') != normalized) {
        return false;
      }
    } catch (_) {
      return false;
    }
    final keys = await load();
    keys.add(normalized);
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_key, keys.toList()..sort());
  }

  Future<bool> revoke(String value) async {
    final keys = await load();
    keys.remove(value);
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_key, keys.toList()..sort());
  }
}
