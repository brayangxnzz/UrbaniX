# Urbanix V3 — candidato de integración 1.0

Aplicación Flutter para **emitir y verificar QR del entorno V3** con Ed25519. La pantalla incluye emisión, copia del contenido QR, validación, consumo local y registro explícito de claves públicas de emisores.

## Estado verificado
- Se corrigió error de compilación evidente de V0.9 (`providedPublic` no definida en restauración de claves).
- Se evita regenerar silenciosamente una identidad incompleta en almacenamiento seguro.
- Ejecutadas 18 pruebas del protocolo Python de referencia: **18/18 aprobadas**.
- **No fue posible ejecutar `flutter pub get`, `flutter test` ni generar un APK:** Flutter y Android SDK no están disponibles en el entorno. **El código Dart no tiene todavía validación de compilación.**

## Cómo compilar y probar en equipo con Flutter
```bash
flutter create --platforms=android .
flutter pub get
flutter analyze
flutter test
flutter run
# opcional, APK: flutter build apk --release
```

## Prueba manual entre dos teléfonos
1. En el emisor A, copia la clave pública y entrégala por un canal confiable al validador B.
2. En B, regístrala en «Emisores de confianza».
3. En A, genera un pase V3 y copia su contenido de texto al validador B.
4. En B, comprueba firma y vigencia; después selecciona «Aceptar y registrar uso».
5. Repite la aceptación en B: debe rechazar el mismo código. Cambia un carácter: debe fallar la firma. Prueba el vencimiento transcurridos 15 minutos.

**Limitaciones importantes:** no incluye lectura mediante cámara; por ahora se transfiere el contenido del QR como texto. Los registros de uso son **locales a cada validador** y no evitan reutilización entre distintos lectores; requeriría una base compartida. No hay contabilidad central ni entrega/pago de tickets. El esquema QR V3 **no es compatible con el antiguo formato cifrado V2**, ni un pase para lectores oficiales.

No desinstales Urbanix V2 ni borres sus datos.
