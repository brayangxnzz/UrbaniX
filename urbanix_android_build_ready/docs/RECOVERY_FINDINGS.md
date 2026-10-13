# Evidencia técnica y límites de recuperación

## Confirmado por los archivos

- El APK contiene `libapp.so` en arquitecturas ARMv7 y ARM64, además del motor Flutter. Ver huellas y longitudes exactas en `apk_evidence.json`.
- Los archivos binarios incluyen las cadenas `installation_id`, `key_fingerprint`, `tickets_v2`, `urbanix/v2/enc`, `urbanix/v2/mac`, `qrGenerationFailed` y `la clave del QR debe tener 16 bytes`. Una cadena literal no demuestra el algoritmo que la consume.
- Manual, pp. 7–15: compra de al menos cinco tickets, envío de un código a Telegram, confirmación de pago, código de entrega y prevención documentada de cargas duplicadas.
- Manual, pp. 16–24: transporte, 1–9 pasajeros, QR por 15 minutos y descuento de saldos.
- Mensajes compartidos: solicitud app→bot con dos bloques Base64 y separador final; entrega bot→app con cuatro bloques y cabecera JSON decodificable (`v`, `installation_id`, `key_fingerprint`, `operation_id`). Los bloques restantes no son texto en claro.
- Comportamiento comunicado: QR funciona sin internet; el saldo permanece tras reiniciar, el QR activo desaparece al cerrar la aplicación.

## Aún no demostrado

- Dónde se define el material criptográfico y si el QR utiliza las mismas claves que la entrega del bot.
- Semántica del contenido binario del QR (una muestra no basta para inferir campos).
- Algoritmo completo de generación de QR V2, contenido de llaves o compatibilidad con verificadores preexistentes.

## Siguiente experimento legítimo y reproducible

Conservando la app original y sin publicar claves, preparar **vectores de prueba caducados**: dos QR creados en la misma instalación bajo condiciones conocidas, con sus bytes originales, transporte, pasajeros y hora de emisión, además de resultados del validador propio. Esto permite comparar longitudes, variación e invariantes, sin presumir que las diferencias visibles implican un algoritmo concreto.

La ingeniería inversa estructural del código compilado puede continuar, pero no debe confundirse con recuperar el Dart original. Para compatibilidad real de V2 es necesario reproducir su protocolo de forma autorizada y demostrarlo en pruebas controladas.
