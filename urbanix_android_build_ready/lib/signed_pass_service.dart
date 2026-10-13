import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Formato URBANIX_V3: auténtico en esta instalación, NO interoperable con V2.
/// La clave privada se guarda usando almacenamiento seguro del dispositivo.
class SignedPassService {
  static const routes = <String>['Metro','Transmetro','Ruta Integrada','Muevo León'];
  static const validity = Duration(minutes: 15);
  static const _secure = FlutterSecureStorage();
  static const _privateKeyName = 'urbanix_v3_sign_private';
  static const _publicKeyName = 'urbanix_v3_sign_public';
  final Ed25519 _algorithm = Ed25519();

  Future<SimpleKeyPair> _keyPair() async {
    final secret = await _secure.read(key: _privateKeyName);
    final public = await _secure.read(key: _publicKeyName);
    if (secret != null && public != null) {
      if (base64Decode(secret).length != 32 || base64Decode(public).length != 32) {
        throw StateError('Identidad criptográfica dañada; no se reemplazará automáticamente');
      }
      return SimpleKeyPairData(base64Decode(secret), publicKey: SimplePublicKey(base64Decode(public), type: KeyPairType.ed25519), type: KeyPairType.ed25519);
    }
    if (secret != null || public != null) {
      throw StateError('Identidad criptográfica incompleta; se requiere recuperación');
    }
    // La clave privada nunca se incorpora al QR.
    final pair = await _algorithm.newKeyPair();
    final data = await pair.extract();
    final pub = await pair.extractPublicKey();
    await _secure.write(key: _privateKeyName, value: base64Encode(data.bytes));
    await _secure.write(key: _publicKeyName, value: base64Encode(pub.bytes));
    return pair;
  }

  Future<String> issue({required String route, required int passengers, required DateTime now}) async {
    if (!routes.contains(route)) throw ArgumentError('Transporte desconocido');
    if (passengers < 1 || passengers > 9) throw RangeError.range(passengers, 1, 9);
    final pair = await _keyPair();
    final public = await pair.extractPublicKey();
    final secureRandom = Random.secure();
    final nonce = List<int>.generate(16, (_) => secureRandom.nextInt(256));
    final payload = <String,dynamic>{
      'format':'URBANIX_V3_INTERNAL', 'version':3,
      'id':base64UrlEncode(nonce).replaceAll('=', ''),
      'route':route, 'passengers':passengers,
      'issued_at':now.toUtc().millisecondsSinceEpoch,
      'expires_at':now.toUtc().add(validity).millisecondsSinceEpoch,
    };
    final message = base64UrlEncode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
    final signed = await _algorithm.sign(utf8.encode(message), keyPair: pair);
    final keyId = base64UrlEncode(public.bytes).replaceAll('=', '');
    return 'UV3.$message.${base64UrlEncode(signed.bytes).replaceAll('=', '')}.$keyId';
  }

  /// Un verificador externo debe registrar previamente la clave pública del emisor.
  /// No se acepta una clave pública aportada únicamente por el código QR.
  Future<String> exportIssuerPublicKey() async {
    final pair = await _keyPair();
    final public = await pair.extractPublicKey();
    return base64UrlEncode(public.bytes).replaceAll('=', '');
  }

  Future<PassCheck> verify(String qr, {
    required DateTime now,
    bool consume = false,
    Set<String>? trustedIssuerKeys,
  }) async {
    try {
      final segments = qr.split('.');
      if (segments.length != 4 || segments[0] != 'UV3') return const PassCheck(false,'Formato no reconocido');
      final localPublic = await _secure.read(key: _publicKeyName);
      final localKey = localPublic == null ? null : base64UrlEncode(base64Decode(localPublic)).replaceAll('=', '');
      final trusted = trustedIssuerKeys ?? <String>{if (localKey != null) localKey};
      if (!trusted.contains(segments[3])) {
        return const PassCheck(false,'Emisor no autorizado');
      }
      final providedPublic = base64Url.decode(base64Url.normalize(segments[3]));
      if (providedPublic.length != 32) return const PassCheck(false,'Clave pública inválida');
      final decoded = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(segments[1]))));
      if (decoded is! Map<String,dynamic> || decoded['format'] != 'URBANIX_V3_INTERNAL' || decoded['version'] != 3) return const PassCheck(false,'Campos incompatibles');
      final route = decoded['route']; final passengers = decoded['passengers'];
      final id = decoded['id']; final issued = decoded['issued_at']; final expires = decoded['expires_at'];
      if (route is! String || !routes.contains(route) || passengers is! int || passengers < 1 || passengers > 9 || id is! String || id.isEmpty || issued is! int || expires is! int || expires-issued != validity.inMilliseconds) return const PassCheck(false,'Campos o vigencia inválidos');
      final signature = Signature(base64Url.decode(base64Url.normalize(segments[2])), publicKey: SimplePublicKey(providedPublic, type: KeyPairType.ed25519));
      if (!await _algorithm.verify(utf8.encode(segments[1]), signature: signature)) return const PassCheck(false,'Firma criptográfica inválida');
      final time = now.toUtc().millisecondsSinceEpoch;
      if (issued > time || time >= expires) return const PassCheck(false,'QR fuera de vigencia');
      final prefs = await SharedPreferences.getInstance();
      final key = 'urbanix_v3_used_$id';
      if (prefs.getBool(key) ?? false) return const PassCheck(false,'QR utilizado anteriormente');
      if (consume) {
        final written = await prefs.setBool(key,true);
        if (!written) return const PassCheck(false,'No se pudo registrar el uso');
      }
      return PassCheck(true,consume ? 'Pase aceptado y registrado' : 'Firma auténtica; todavía no consumido', route:route, passengers:passengers);
    } catch (_) { return const PassCheck(false,'No se pudo verificar el QR'); }
  }
}
class PassCheck {
  final bool valid; final String message; final String? route; final int? passengers;
  const PassCheck(this.valid,this.message,{this.route,this.passengers});
}
