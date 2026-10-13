# Actualizar UrbaniX desde la Mac, sin Android Studio

Repositorio existente: `https://github.com/brayangxnzz/UrbaniX`

## Opción sencilla: GitHub Web

1. Descomprime `Urbanix_V3_Final_Flutter.zip`.
2. En la raíz del repositorio, utiliza **Add file → Upload files** y sube los contenidos manteniendo exactamente las rutas de la carpeta `urbanix_android_build_ready/`. Si GitHub no permite sobrescribir algunos archivos, edítalos desde el icono del lápiz o utiliza GitHub Desktop.
3. Verifica la ubicación de `.github/workflows/build-apk.yml` en la **raíz de UrbaniX**, NO dentro de `urbanix_android_build_ready`.
4. GitHub → **Actions** → **Compilar Urbanix V3 Android** → **Run workflow**.
5. Al finalizar, descarga el artefacto `urbanix-v3-apk` y extrae `app-debug.apk`.

## Opción Terminal (para manejar sustituciones de archivos)

En la Mac con Git instalado, desde una carpeta donde quieras guardar el proyecto:

```bash
git clone https://github.com/brayangxnzz/UrbaniX.git
cd UrbaniX
# Descomprime el ZIP en una carpeta externa y copia sus contenidos a esta carpeta
# Debes preservar .github/ en la raíz y urbanix_android_build_ready/ con sus archivos.
git add -A
git commit -m "Urbanix V3: interfaz, saldo, QR y validador"
git push origin main
```

No pegues el ZIP como archivo en el repositorio: GitHub Actions necesita ver los `.dart` y `pubspec.yaml` descomprimidos.

La compilación puede revelar errores Dart adicionales que no se pueden comprobar aquí porque no hay Flutter SDK; el flujo parará antes del APK si fallan el análisis o las pruebas. Así se evitan artefactos de una compilación defectuosa.
