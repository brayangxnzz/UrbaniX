#!/usr/bin/env python3
"""Inventario conservador de cadenas para libapp.so de Urbanix."""
import argparse, hashlib, json
from pathlib import Path
TERMS = ['qrGenerationFailed','tickets_v2','urbanix/v2/enc','urbanix/v2/mac','RSA_ECB_PKCS1Padding','AES_CBC_PKCS7Padding','rsa_private_key','rsa_public_key','installation_id','operation_id','key_fingerprint','la clave del QR debe tener 16 bytes','ticket.type','rsa_unwrap_failed','aes_decrypt_failed']
def inspect(binary):
    b=Path(binary).read_bytes()
    return {'sha256':hashlib.sha256(b).hexdigest(),'size':len(b),'matches':[{'term':t,'offset':hex(b.find(t.encode())) if t.encode() in b else None} for t in TERMS]}
if __name__=='__main__':
    ap=argparse.ArgumentParser(); ap.add_argument('libapp_so'); args=ap.parse_args(); print(json.dumps(inspect(args.libapp_so), indent=2,ensure_ascii=False))
