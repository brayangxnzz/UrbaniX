import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanix_recovery/protocol_inspector.dart';

void main() {
  test('Detecta envoltura de dos segmentos con separador final', () {
    final result = ProtocolInspector().inspect('YWJj.ZGVm.');
    expect(result.segments, 2);
    expect(result.decodedByteLengths, [3, 3]);
    expect(result.structurallyBase64, true);
  });
  test('Lee solo los metadatos de cabecera de entregas simuladas', () {
    final header = base64.encode(utf8.encode(jsonEncode({
      'v': 2, 'installation_id': 'ficticio', 'operation_id': 'op-demo',
      'key_fingerprint': 'solo-test', 'secret': 'NO_EXHIBIR',
    })));
    final result = ProtocolInspector().inspect('$header.YQ==.Yg==.Yw==');
    expect(result.segments, 4);
    expect(result.publicHeaderFields['v'], '2');
    expect(result.publicHeaderFields.containsKey('secret'), false);
  });
  test('Rechaza caracteres ajenos a Base64', () {
    final result = ProtocolInspector().inspect('abc*.YQ==');
    expect(result.structurallyBase64, false);
  });
}
