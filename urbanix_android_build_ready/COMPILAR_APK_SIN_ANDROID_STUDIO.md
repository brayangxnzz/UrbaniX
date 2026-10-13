# Compilar Urbanix V3 sin Android Studio (GitHub Actions)

Este proyecto **no contiene todavía** un APK compilado. El flujo de GitHub Actions crea la estructura nativa de Android y compila un `app-debug.apk` firmado automáticamente con una clave de depuración. Este APK es para pruebas, **no** para distribución pública. La compilación aún no fue ejecutada en este entorno.

## Desde navegador
1. Crea un repositorio **privado** vacío en github.com/new, por ejemplo `urbanix-v3` (no marques README).
2. En tu Mac, descomprime el ZIP. Abre Terminal **dentro de la carpeta `urbanix_android_build_ready`** y ejecuta:

```bash
git init
git add .
git commit -m "Primera compilación Urbanix V3"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/urbanix-v3.git
git push -u origin main
```

   GitHub requiere autenticación al hacer push. Puedes usar GitHub Desktop si prefieres evitar Terminal.
3. Abre el repositorio en GitHub > **Actions** > **Compilar Urbanix APK** > **Run workflow** > **Run workflow**. El flujo también se inicia automáticamente cuando subes a `main`.
4. Si el trabajo termina correctamente, abre su ejecución y descarga el artefacto `Urbanix-V3-APK-Android`.
5. Descomprime el artefacto: contendrá `app-debug.apk`. Pásalo al Android y ábrelo. Autoriza *Instalar aplicaciones desconocidas* solo para el gestor de archivos o navegador usado.

## Advertencias
- Es un APK **debug** firmado para pruebas; no es un APK release de publicación.
- Usa ID de aplicación distinto de V2 (prefijo `com.urbanixv3`) para reducir el riesgo de sobrescribir V2. Verifica el identificador antes de instalar.
- No borres ni desinstales la app V2.
- Los QR emitidos son **del protocolo interno V3**, no equivalentes al sistema V2.
- Los registros de consumo se guardan por validador. No hay sincronización multi-dispositivo ni lector de cámara.
- Si GitHub Actions falla, consulta el primer paso rojo y comparte su registro. No se ha verificado que el código Flutter compile sin errores.
