import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'signed_pass_service.dart';

/// El saldo es de pruebas y reside únicamente en esta instalación.
/// La emisión y el descuento se guardan juntos en un documento persistente.
class WalletController extends ChangeNotifier {
  static const storageKey = 'urbanix_v3_demo_wallet_v1';
  final SignedPassService passService;
  WalletController(this.passService);
  WalletData _data = WalletData.initial();
  WalletData get data => _data;
  bool loading = true;
  bool _busy = false;
  String? error;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(storageKey);
      if (stored == null) {
        _data = WalletData.initial();
        if (!await prefs.setString(storageKey, _data.encode())) {
          throw StateError('No se pudo guardar el saldo inicial');
        }
      } else {
        _data = WalletData.decode(stored);
      }
    } catch (e) {
      error = 'No se pudieron abrir los datos: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _save(WalletData next) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(storageKey, next.encode())) {
      throw StateError('No se pudo persistir la operación');
    }
    _data = next;
    notifyListeners();
  }

  String _makeId() {
    final rng = Random.secure();
    return List<int>.generate(16, (_) => rng.nextInt(256))
        .map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> setProfile(String name, String gender) async {
    if (name.trim().length < 3) throw ArgumentError('Nombre mínimo de 3 caracteres');
    await _save(_data.copyWith(profileName: name.trim(), gender: gender));
  }

  Future<void> addDemoTickets(String route, int count) async {
    if (_busy) throw StateError('Hay una operación en curso');
    if (RouteInfo.find(route) == null || count < 1 || count > 20) {
      throw ArgumentError('Cantidad o transporte inválido');
    }
    _busy = true;
    try {
      final current = _data.count(route);
      if (current + count > 100000) throw StateError('Límite de tickets');
      final next = Map<String, int>.of(_data.tickets)..[route] = current + count;
      final entry = WalletEntry(id: _makeId(), route: route, count: count,
        fareCents: RouteInfo.find(route)!.fareCents,
        occurredAt: DateTime.now().millisecondsSinceEpoch, kind: 'credit');
      await _save(_data.copyWith(tickets: next, entries: [entry, ..._data.entries]));
    } finally { _busy = false; }
  }

  Future<ActivePass> issue(String route, int passengers) async {
    if (_busy) throw StateError('Hay una operación en curso');
    final info = RouteInfo.find(route);
    if (info == null || passengers < 1 || passengers > 9) {
      throw ArgumentError('Datos del viaje no válidos');
    }
    if (_data.activePass != null && DateTime.now().millisecondsSinceEpoch < _data.activePass!.expiresAt) {
      throw StateError('Ya tienes un pase activo; espera a que venza');
    }
    if (_data.count(route) < passengers) {
      throw StateError('No tienes tickets suficientes');
    }
    _busy = true;
    try {
      final now = DateTime.now();
      final token = await passService.issue(route: route,
        passengers: passengers, now: now);
      final pass = ActivePass(code: token, route: route, passengers: passengers,
        expiresAt: now.add(SignedPassService.validity).millisecondsSinceEpoch);
      final tickets = Map<String, int>.of(_data.tickets)
        ..[route] = _data.count(route) - passengers;
      final entry = WalletEntry(id: _makeId(), route: route,
        count: passengers, fareCents: info.fareCents,
        occurredAt: now.millisecondsSinceEpoch, kind: 'trip');
      // Un único documento persistente evita guardar el débito sin el QR activo.
      await _save(_data.copyWith(tickets: tickets,
        entries: [entry, ..._data.entries], activePass: pass));
      return pass;
    } finally { _busy = false; }
  }
}
