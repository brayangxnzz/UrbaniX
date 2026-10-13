# Comparación reproducible de un QR histórico

Se leyó **directamente** `IMG_5580.JPG` mediante OpenCV y se comprobó que
contiene 512 caracteres Base64 que decodifican a 384 bytes.
La huella SHA-256 de los bytes figura en `original_qr_sample_metadata.json`.
El ejemplo original NO se incrusta en el repositorio para evitar publicar un
pase o identificador reutilizable.

## Reproducir

```bash
python tools/inspect_qr.py --image /ruta/IMG_5580.JPG
python -m unittest discover -s tools/tests
```

`OriginalQrInspector` permite comparar longitud, codificación y huella en Dart.
**IMPORTANTE:** producir otros 384 bytes no implica que un QR sea válido,
ni que se haya recuperado el algoritmo de V2. Con una sola muestra no puede
inferirse composición criptográfica, propiedades de autenticidad, ni la
relación exacta entre las entregas del bot y los QR de viaje.

## Próxima evidencia técnica necesaria

Una especificación de V2 o vectores de referencia de emisión y validación
dentro de un entorno controlado, con datos y claves de prueba. No utilizar
boletos activos ni poner en riesgo la instalación original.
