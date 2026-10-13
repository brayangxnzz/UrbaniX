#!/usr/bin/env python3
"""Inspección de solo lectura del APK de Urbanix: inventario y texto plano.
No extrae claves, no decodifica boletos y no modifica la aplicación.
Uso: python3 tools/inspect_apk.py /ruta/a/urbanix.apk
"""
import hashlib, json, sys, zipfile
from pathlib import Path

TERMS = ['installation_id', 'key_fingerprint', 'operation_id', 'tickets_v2',
         'urbanix/v2/enc', 'urbanix/v2/mac', 'qrGenerationFailed',
         'rsa_unwrap_failed', 'rsa_private_key', 'rsa_public_key',
         'ticket.type', 'la clave del QR debe tener 16 bytes']

def main(path):
    apk = Path(path)
    if not apk.is_file():
        raise SystemExit('No existe el APK indicado')
    with zipfile.ZipFile(apk) as archive:
        names = archive.namelist()
        candidates = [n for n in names if n.endswith('/libapp.so')]
        report = {'apk_sha256': hashlib.sha256(apk.read_bytes()).hexdigest(),
                  'apk_bytes': apk.stat().st_size,
                  'flutter': any('libflutter.so' in n for n in names),
                  'dart_aot_libraries': [], 'strings_observed': {}}
        for name in candidates:
            b = archive.read(name)
            report['dart_aot_libraries'].append({'name': name, 'bytes': len(b),
                           'sha256': hashlib.sha256(b).hexdigest()})
            report['strings_observed'][name] = [s for s in TERMS if s.encode('utf-8') in b]
    print(json.dumps(report, indent=2, ensure_ascii=False))

if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise SystemExit('Uso: python3 tools/inspect_apk.py urbanix.apk')
    main(sys.argv[1])
