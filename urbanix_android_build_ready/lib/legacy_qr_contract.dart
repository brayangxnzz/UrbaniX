/// Contrato de recuperación de Urbanix V2.
/// Importante: ninguna implementación de este contrato debe atribuir
/// compatibilidad a V2 hasta superar pruebas con vectores auténticos
/// y con un verificador propio autorizado.
class LegacyQrRequest {
  final String transport;
  final int passengers;
  final DateTime issuedAt;
  final String installationId;
  const LegacyQrRequest({required this.transport, required this.passengers,
    required this.issuedAt, required this.installationId});
}

class CompatibilityResult {
  final bool compatible;
  final String explanation;
  final String? payload;
  const CompatibilityResult({required this.compatible,
    required this.explanation, this.payload});
}

abstract class LegacyQrEmitter {
  Future<CompatibilityResult> issue(LegacyQrRequest request);
}

/// Esta implementación es deliberadamente honesta: no produce QR V2.
/// La rutina exacta y el material criptográfico necesario no se han recuperado.
class UnavailableLegacyQrEmitter implements LegacyQrEmitter {
  @override
  Future<CompatibilityResult> issue(LegacyQrRequest request) async {
    if (!const ['Metro', 'Transmetro', 'Ruta Integrada', 'Muevo León']
        .contains(request.transport) || request.passengers < 1 ||
        request.passengers > 9 || request.installationId.isEmpty) {
      return const CompatibilityResult(compatible: false,
        explanation: 'Solicitud inválida.');
    }
    return const CompatibilityResult(compatible: false,
      explanation: 'No se ha recuperado el algoritmo V2 ni sus claves. '
        'No es posible emitir un QR que se afirme compatible.');
  }
}
