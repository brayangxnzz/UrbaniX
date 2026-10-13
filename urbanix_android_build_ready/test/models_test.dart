import 'package:flutter_test/flutter_test.dart';
import 'package:urbanix_recovery/models.dart';

void main() {
  test('Saldo demo inicial y tarifas del manual Urbanix V2', () {
    final state = WalletData.initial();
    expect(state.totalTickets, 20);
    expect(state.count('Metro'), 5);
    expect(state.count('Muevo León'), 5);
    expect(RouteInfo.find('Metro')!.fareCents, 900);
    expect(RouteInfo.find('Transmetro')!.fareCents, 1500);
    expect(RouteInfo.find('Ruta Integrada')!.fareCents, 1500);
    expect(RouteInfo.find('Muevo León')!.fareCents, 1650);
    expect(state.balanceCents, 27750);
  });

  test('Se conservan QR activos y transacciones al serializar', () {
    final original = WalletData.initial().copyWith(
      activePass: const ActivePass(code: 'UV3.test', route: 'Metro',
        passengers: 1, expiresAt: 1990000000000),
      entries: [const WalletEntry(id: 'id', route: 'Metro',
        count: 1, fareCents: 900, occurredAt: 1770000000000, kind: 'trip')],
    );
    final decoded = WalletData.decode(original.encode());
    expect(decoded.activePass?.code, 'UV3.test');
    expect(decoded.entries.single.route, 'Metro');
    expect(decoded.totalTickets, 20);
  });

  test('Saldo persistido malformado no se acepta silenciosamente', () {
    final data = WalletData.initial().encode().replaceFirst('"Metro":5', '"Metro":-1');
    expect(() => WalletData.decode(data), throwsFormatException);
  });
}
