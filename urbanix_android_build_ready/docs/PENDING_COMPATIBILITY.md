# Urbanix V2: pendientes de compatibilidad (V0.5)

## Avance comprobable
- Comparación no destructiva de una o varias capturas QR o textos originales.
- Comparación con una huella de muestra aportada por el usuario (sin incluir el QR completo).
- Separación obligatoria entre coincidencia de bytes, parecido estructural, autenticidad y validación.
- El QR de referencia observado tiene 512 caracteres Base64 / 384 bytes y SHA-256 `a9e7b48699002b6e7e592fe71c527e906258dd1326e38825ceb2bba12fd1b87a`.

## Pendiente sin evidencia suficiente
- Algoritmo y estructura interna de los 384 bytes, material de claves, nonce/IV, campos firmados.
- Reproducibilidad de emisión por V2 con entradas controladas.
- Compatibilidad con el validador existente de la plataforma.

## Prueba reproducible
`python tools/compare_legacy_qr.py --image /ruta/IMG_5580.JPG`
`python -m unittest discover -s tools/tests -v`

**Una huella igual reconoce exactamente el mismo contenido**, no garantiza que sea válido o no haya expirado. Dos QR distintos válidos pueden tener huellas diferentes.

## Próximo experimento dentro de la plataforma propia
Usar un entorno controlado y credenciales de prueba: registrar dos QR caducados con transporte, número de pasajeros, hora y respuesta del validador propio. Comparar ambos con la herramienta. No incluir claves, tokens ni datos privados en archivos compartidos. No tocar o reinstalar V2.
