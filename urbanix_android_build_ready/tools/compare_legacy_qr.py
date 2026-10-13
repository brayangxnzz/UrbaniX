#!/usr/bin/env python3
"""Comparación forense de QR de Urbanix V2 (solo lectura).
Compara las propiedades observables; NUNCA certifica autenticidad o uso.
Ejemplo: python tools/compare_legacy_qr.py --image imagen_a.jpg --image imagen_b.jpg
"""
import argparse, base64, binascii, hashlib, json
from pathlib import Path

REFERENCE_SHA256 = "a9e7b48699002b6e7e592fe71c527e906258dd1326e38825ceb2bba12fd1b87a"

def inspect_qr_text(text):
    text=text.strip()
    if not text or len(text)>16384:
        return {'base64':False, 'reason':'texto vacío o excede el límite'}
    try:
        data=base64.b64decode(text,validate=True)
    except (ValueError,binascii.Error):
        return {'base64':False, 'reason':'Base64 inválido'}
    canonical=base64.b64encode(data).decode('ascii')==text
    sha=hashlib.sha256(data).hexdigest()
    return {'base64':True,'canonical_base64':canonical,'text_characters':len(text),
      'decoded_bytes':len(data),'sha256':sha,'same_bytes_as_reference':sha==REFERENCE_SHA256,
      'same_observed_shape':canonical and len(text)==512 and len(data)==384,
      'authenticity':'NOT VERIFIED','accepted_by_legacy_validator':'NOT TESTED'}

def compare_texts(texts):
    results=[inspect_qr_text(t) for t in texts]
    sha=[r.get('sha256') for r in results]
    return {'samples':results, 'all_same_bytes':len(sha)>1 and all(s is not None and s==sha[0] for s in sha),
        'compatibility_conclusion':'No se puede concluir compatibilidad por tamaño, Base64 o coincidencia de hash.'}

def read_image(path):
    try: import cv2
    except ImportError: raise RuntimeError('Para imágenes instala opencv-python')
    img=cv2.imread(str(path))
    if img is None: raise ValueError('No se pudo leer imagen: '+str(path))
    data,_,_=cv2.QRCodeDetector().detectAndDecode(img)
    if not data: raise ValueError('No se pudo extraer QR: '+str(path))
    return data

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--image',action='append',type=Path,default=[])
    p.add_argument('--text-file',action='append',type=Path,default=[])
    a=p.parse_args()
    if not a.image and not a.text_file:p.error('Proporciona --image o --text-file')
    texts=[read_image(p) for p in a.image]+[p.read_text(encoding='utf8') for p in a.text_file]
    print(json.dumps(compare_texts(texts),indent=2,ensure_ascii=False))
if __name__=='__main__':main()
