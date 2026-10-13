# Investigación del generador original (Urbanix V2)

## Comprobaciones reproducibles

El `libapp.so` ARM64 del APK es un objeto ELF64 AArch64 con un snapshot AOT de Dart (`_kDartIsolateSnapshotData` y `_kDartIsolateSnapshotInstructions`). La tabla pública de símbolos contiene los símbolos del snapshot, **no** una lista de funciones Dart de aplicación recuperadas. Las cadenas catalogadas en `AOT_OFFSETS.json` están en `.rodata`, con posiciones de archivo verificables y SHA-256 del binario para trazabilidad.

Las cadenas `qrGenerationFailed`, `tickets_v2`, `la clave del QR debe tener 16 bytes`, `RSA_ECB_PKCS1Padding`, `AES_CBC_PKCS7Padding`, `urbanix/v2/enc` y `urbanix/v2/mac` aparecen realmente, pero estar presentes en el mismo binario **no demuestra** que formen un único algoritmo de QR ni proporciona el flujo de control.

## Estado de la compatibilidad

- Lectura de QR histórico: sí, según la muestra del proyecto anterior.
- Formato observable del QR histórico: cadena Base64 de 512 caracteres que decodifica a 384 bytes.
- Emisor original Dart reconstruido: **no**.
- Validación con el mecanismo de V2: **no probada**.
- Credenciales y reglas de emisión: **desconocidas**.

## Próximo paso de investigación

Para recuperar la rutina original, se necesita análisis específico de snapshots AOT para la versión de Flutter/Dart correspondiente, con una reconstrucción verificable del flujo de control, seguida de pruebas de caja negra en un entorno de validación administrado por el dueño del proyecto. No se debe suponer RSA-3072 a partir de 384 bytes, ni declarar compatibilidad solamente por igualdad de longitud.

No se incluyeron datos privados de tickets ni se modificó el APK.
