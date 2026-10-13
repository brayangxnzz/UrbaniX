import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbanix_recovery/signed_pass_service.dart';
import 'package:urbanix_recovery/wallet_controller.dart';

class FakePassService extends SignedPassService {
  @override
  Future<String> issue({required String route, required int passengers,
    required DateTime now}) async => 'UV3.mock.$route.$passengers';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('La carga demo incrementa tickets y sobrevive a reinicio', () async {
    final a = WalletController(FakePassService());
    await a.initialize();
    expect(a.data.count('Metro'), 5);
    await a.addDemoTickets('Metro', 2);
    expect(a.data.count('Metro'), 7);
    final b = WalletController(FakePassService());
    await b.initialize();
    expect(b.data.count('Metro'), 7);
    expect(b.data.entries.single.kind, 'credit');
  });

  test('Emisión descuenta pasajeros y conserva el mismo QR', () async {
    final a = WalletController(FakePassService());
    await a.initialize();
    final pass = await a.issue('Muevo León', 2);
    expect(a.data.count('Muevo León'), 3);
    expect(a.data.activePass?.code, pass.code);
    final b = WalletController(FakePassService());
    await b.initialize();
    expect(b.data.count('Muevo León'), 3);
    expect(b.data.activePass?.code, pass.code);
  });

  test('No emite un segundo QR activo ni descuenta saldo nuevamente', () async {
    final a = WalletController(FakePassService());
    await a.initialize();
    await a.issue('Metro', 1);
    await expectLater(a.issue('Metro', 1), throwsStateError);
    expect(a.data.count('Metro'), 4);
  });

  test('Rechaza viajes sin saldo y cantidades inválidas', () async {
    final a = WalletController(FakePassService());
    await a.initialize();
    await expectLater(a.issue('Metro', 9), throwsStateError);
    await expectLater(a.issue('Metro', 0), throwsArgumentError);
    await expectLater(a.addDemoTickets('Metro', 21), throwsArgumentError);
    expect(a.data.count('Metro'), 5);
  });
}
