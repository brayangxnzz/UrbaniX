# Estado técnico comprobado — Urbanix V3 / V0.9

## Sí implementado
- Emisión de pases internos V3: payload con ruta, pasajeros, nonce, fechas de creación y expiración.
- Firma Ed25519. Validación con clave pública previamente autorizada, no confiando ciegamente en la clave incluida en el QR.
- Rechazo de firmas alteradas, rutas no admitidas, número de pasajeros fuera de rango, fechas inválidas, códigos expirados y QR usados previamente (registro local).
- 15 minutos de vigencia y 1 a 9 pasajeros.
- Exportación de clave pública para configurar otro verificador.

## Límites que impiden declarar compatibilidad exacta con V2
- El QR histórico aporta 384 bytes de contenido binario, pero una sola muestra no revela el esquema que produce dichos bytes.
- La versión V3 usa `UV3` + JSON Base64URL + firma Ed25519. No es el mismo formato de V2.
- Sin acceso a la implementación/credenciales correspondientes o a un validador V2 no hay base para certificar que V3 emite QR aceptados por V2.
- Replay se registra **localmente** en el dispositivo validador. Para varios validadores se necesita una base sincronizada que aplique unicidad atómica.
- Claves por instalación: reinstalar puede invalidar su identidad; respaldar y enrolar emisor de forma controlada.
- Ausencia del SDK Flutter en este entorno: el código Flutter no fue compilado ni probado en un Android real.

## Seguridad y operación
- No se incorporan claves del proyecto antiguo ni boletos históricos.
- El campo de clave pública del QR se usa solo tras verificar que aparece en la lista previa de emisores confiables.
- El botón de la aplicación valida y registra consumos locales; no sustituye un validador independiente.
- Los componentes `qr_demo_service` y `demo_pass_verifier` siguen incluidos únicamente para comparación histórica; no forman parte del emisor firmado.
