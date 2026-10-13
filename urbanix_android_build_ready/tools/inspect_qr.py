#!/usr/bin/env python3
"""Analiza la codificación y huella SHA-256 de un QR, sin validar billetes.
Uso: python tools/inspect_qr.py --image IMG_5580.JPG
Requiere opencv-python solo para leer imágenes; con --text-file usa stdlib.
No imprime el contenido potencialmente sensible de un pase.
"""
import argparse, base64, hashlib, json, pathlib

def analyse(value):
    value=value.strip()
    try: raw=base64.b64decode(value,validate=True)
    except (ValueError,base64.binascii.Error): return {'valid_base64':False,'characters':len(value)}
    return {'valid_base64':True,'characters':len(value),'decoded_bytes':len(raw),
            'sha256':hashlib.sha256(raw).hexdigest(),
            'matches_single_observed_sample_shape':len(value)==512 and len(raw)==384,
            'valid_ticket':'not determined'}

def main():
    parser=argparse.ArgumentParser()
    x=parser.add_mutually_exclusive_group(required=True)
    x.add_argument('--image',type=pathlib.Path)
    x.add_argument('--text-file',type=pathlib.Path)
    args=parser.parse_args()
    if args.image:
        try: import cv2
        except ImportError: parser.error('Para --image instala opencv-python')
        image=cv2.imread(str(args.image))
        if image is None: parser.error('No se pudo abrir la imagen')
        value,_,_=cv2.QRCodeDetector().detectAndDecode(image)
        if not value: parser.error('No se pudo decodificar el QR de la imagen')
    else: value=args.text_file.read_text(encoding='utf-8')
    print(json.dumps(analyse(value),indent=2,ensure_ascii=False))

if __name__=='__main__': main()
