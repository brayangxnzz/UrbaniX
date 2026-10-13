# Urbanix V2 — diagnóstico de compatibilidad y recuperación

## Evidencia verificada

- APK examinado: `urbanix.apk`; SHA-256 `7291de1981f978d24c9f0e7b928a89e036871cdd81f9f20fd775420f46593173`.
- Biblioteca principal `lib/arm64-v8a/libapp.so` de Flutter/Dart AOT; SHA-256 `9bcc7299b6dfb7bdf022aadfd300368353175fb85996e9c971c99c87df8d9b74`.
- La tabla ELF expone símbolos del *snapshot* Dart (`_kDartIsolateSnapshotData`, `_kDartIsolateSnapshotInstructions`), pero no expone directamente los métodos de la aplicación como código Dart editable.
- Referencias reconocibles en el snapshot: `tickets_v2`, `qrGenerationFailed`, `rsa_private_key`, `rsa_public_key`, `RSA_ECB_PKCS1Padding`, `AES_CBC_PKCS7Padding`, `urbanix/v2/enc`, `urbanix/v2/mac`, `installation_id`, `key_fingerprint`.
- La muestra visual del QR examinada en versiones anteriores contiene una cadena Base64 de 512 caracteres / 384 bytes. SHA-256 de los bytes decodificados: `a9e7b48699002b6e7e592fe71c527e906258dd1326e38825ceb2bba12fd1b87a`.
- La entrega del bot muestra metadatos de instalación, huella de clave y operación; no se ha comprobado una transformación directa entre esa entrega y el contenido del QR.

## Lo que NO está demostrado

- Algoritmo específico que convierte un ticket en un QR.
- Distribución de campos dentro de los 384 bytes (ni modo de cifrado, firma, nonce o IV).
- Acceso a las claves originales de emisión o verificación; dichas claves pueden permanecer en el almacenamiento privado del teléfono original.
- Reproducción byte a byte o aceptación de QR nuevos por el validador de Urbanix V2.

## Resultado

**No se puede declarar terminada la compatibilidad V2.** El proyecto V0.6 sigue incluyendo generación/verificación de DEMOSTRACIÓN, no el emisor original reconstruido.

## Ruta de finalización comprobable

1. Conservar sin cambios la instalación original y respaldo del APK.
2. Obtener el código o configuración del **validador propio Urbanix** y la especificación/credenciales autorizadas de emisión, si existen. No compartir secretos por chat.
3. Si no existe validador disponible, aislar la rutina AOT mediante análisis de flujo de control especializado y validarla en un entorno de prueba propio. Los nombres de cadenas y una sola muestra no bastan para reconstruirla.
4. Implementar el emisor en Dart con pruebas de vectores y verificarlo contra el validador de Urbanix antes de declarar compatibilidad.
5. Después integrar saldo persistente, expiración y el resto de funciones, manteniendo la semántica de la versión anterior.

## Criterio de aceptación

Un pase recién emitido por la implementación reconstruida debe ser reconocido como válido por el **validador de prueba autorizado de Urbanix V2**, y los pases alterados, caducados o duplicados deben ser rechazados. El mero hecho de generar 384 bytes no satisface esta condición.
