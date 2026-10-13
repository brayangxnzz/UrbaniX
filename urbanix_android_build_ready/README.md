# Urbanix V3 — App funcional de prueba

**Proyecto Flutter editable** basado visualmente en el manual de Urbanix V2 de agosto de 2026 y en sus cuatro ilustraciones de rutas extraídas del APK proporcionado por el desarrollador.

## Funciones incluidas

- Inicio con tema violeta, carrusel de Metro / Transmetro / Ruta Integrada / Muevo León, acceso a saldo y validador.
- Saldo por transporte, guardado en el dispositivo con `shared_preferences`.
- Inicialización con **5 tickets ficticios por ruta**. Carga de **1 a 20 tickets de prueba**, sin cobros.
- Selección de **1 a 9 pasajeros** y descuento de un ticket ficticio por pasajero.
- QR de **15 minutos**, emitido offline con firma **Ed25519**, autenticado con claves locales guardadas en `flutter_secure_storage`.
- El QR activo se conserva tras cerrar y volver a abrir la app mientras esté vigente (mejora respecto al comportamiento observado en V2).
- Verificación local: firma, tipo de ruta, cantidad, vigencia, emisor autorizado y registro de uso único en el mismo validador.
- Historial local de recargas y viajes; gasto estimado semanal y del mes.
- Perfil editable, tarifas de referencia y copia de clave pública de emisor.

## Alcance de la validez del QR

**Los QR emitidos por esta versión son válidos exclusivamente en el protocolo interno Urbanix V3 (`UV3`).** Un validador Urbanix V3 con la clave pública del emisor puede comprobar su autenticidad. No comparten el formato criptográfico de Urbanix V2 y no son boletos de transporte oficiales. No hemos recuperado las claves y la función de emisión de V2. Los saldos son datos de prueba: no representan pagos efectuados ni viajes autorizados por operadores externos.

La lista de emisores autorizados y de QR consumidos es **local**. Sin sincronización entre validadores distintos no hay protección global contra doble uso. No se incluye lector de QR por cámara; se valida pegando el texto del código. Telegram y Mercado Pago quedan expresamente pendientes.

## Archivos principales

- `lib/main.dart`: pantallas y navegación.
- `lib/models.dart`: rutas, tarifas, saldo, transacciones y pase activo.
- `lib/wallet_controller.dart`: persistencia, recarga de prueba, emisión + débito.
- `lib/signed_pass_service.dart`: identidad Ed25519, emisión y comprobación.
- `lib/trusted_issuers.dart`: claves públicas de terceros, registradas manualmente.
- `assets/routes/`: imágenes originales de transportes del APK V2.
- `test/`: pruebas Dart de saldo, emisión, serialización y reglas básicas.

## Compilar en GitHub sin Android Studio

La carpeta del proyecto se coloca en la raíz o dentro de `urbanix_android_build_ready/`, según la estructura de tu repositorio.

El archivo de GitHub Actions debe estar **en la raíz del repositorio**: `.github/workflows/build-apk.yml`. El flujo provisto asume que el proyecto está en `urbanix_android_build_ready/`.

1. Sube los archivos nuevos del proyecto a `urbanix_android_build_ready/` en GitHub (reemplazando los antiguos).
2. Sube `build-apk.yml` a `.github/workflows/build-apk.yml` desde la raíz.
3. Actions → **Compilar Urbanix V3 Android** → **Run workflow**.
4. Si las pruebas y la compilación terminan correctamente, descarga el artefacto `urbanix-v3-apk` y extrae `app-debug.apk`.

El APK debug está firmado automáticamente para **instalación y pruebas**, no para Google Play. Una firma debug distinta entre ejecuciones impide instalar actualizaciones sobre una versión previa con el mismo identificador; para distribución persistente utiliza tu propio keystore de release guardado de forma segura.

**No desinstales ni borres los datos de Urbanix V2.** El APK antiguo y su almacenamiento son independientes de este prototipo.

## Verificación

Se ejecutaron **18/18 pruebas de Python del protocolo de referencia previo**. Las pruebas Dart y la compilación Android requieren Flutter en un entorno externo (GitHub Actions ya configurado). Este ZIP es código fuente, **no un APK ya compilado**.
