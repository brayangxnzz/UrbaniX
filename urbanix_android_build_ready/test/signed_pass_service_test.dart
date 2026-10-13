import 'package:flutter_test/flutter_test.dart';
import 'package:urbanix_recovery/signed_pass_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Esta prueba requiere mockear secure storage y shared_preferences en el SDK Flutter.
  test('rutas autorizadas y duración previstas', () {
    expect(SignedPassService.routes, contains('Metro'));
    expect(SignedPassService.routes, contains('Muevo León'));
    expect(SignedPassService.validity, const Duration(minutes: 15));
  });
}
