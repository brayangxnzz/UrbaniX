# Pruebas de aceptación en Android

1. Instalar la nueva V3, entrar a Inicio; comprobar que hay 20 tickets demo (5 por transporte).
2. Saldo → Cargar tickets de prueba → Metro +2; reiniciar la app; deben persistir 7 de Metro.
3. Metro → 2 pasajeros → Generar QR; comprobar 5 de Metro y contador de 15 min.
4. Salir y volver a entrar a la app antes de caducar; Inicio → QR activo debe mostrar el **mismo** código.
5. Cuenta → Verificar QR; copiar el contenido desde la pantalla QR; pegar, comprobar que la firma es auténtica; aceptar; segundo intento debe responder que ya fue utilizado.
6. Volver a emitir un pase recién expirado; comprobar que no se descontó dos veces por el mismo intento.
7. Elegir Transmetro, Ruta Integrada y Muevo León por separado; comprobar imagen, color de QR, 1 a 9 pasajeros y tarifa.
8. Viajes → comprobar importe por los últimos 7 días y el mes; el importe es **referencial**.
9. Cambiar nombre en Cuenta, reiniciar y comprobar persistencia.
10. Probar en modo avión: emitir y verificar QR sigue funcionando.

**Advertencias:** no es el formato V2, no acepta códigos V2, no hay lector de cámara, los tickets son ficticios, y el control de duplicados no se sincroniza entre teléfonos.
