# Política de Privacidad — Pillatelo: Finanzas y Gastos

**Fecha de entrada en vigor:** Octubre de 2026  
**Aplicación:** Pillatelo: Finanzas y Gastos  
**Identificador de paquete (Package ID):** `com.pillatelo.app`  
**Desarrollador:** Amilcar Yujra  

---

### Resumen Ejecutivo
**Pillatelo** es una aplicación móvil diseñada bajo el paradigma **Local-First & Offline**. Toda tu información financiera (ingresos, gastos, cuentas bancarias, deudas, préstamos, metas de ahorro y presupuestos) reside **exclusivamente** en la memoria local de tu dispositivo. Ningún dato personal ni financiero se transfiere, vende, comparte o sincroniza con servidores remotos de terceros.

---

### 1. Información que NO Recopilamos
- **Datos de identificación personal:** No solicitamos nombre completo, identificación nacional, dirección de correo electrónico ni número de teléfono.
- **Acceso bancario remoto:** No nos conectamos a tus credenciales bancarias ni a plataformas de banca por internet.
- **Identificadores comerciales o de publicidad:** No recopilamos el Google Advertising ID ni integramos redes de anuncios o telemetría invasiva.
- **Rastreadores de analítica de terceros:** No usamos Google Analytics, Firebase Analytics, AppsFlyer ni Facebook SDK.

### 2. Almacenamiento Local (SQLite)
Todos los datos registrados en la aplicación se almacenan en una base de datos local **SQLite** (`finanzas_v4.db`) en el almacenamiento protegido y aislado (*sandbox*) del sistema operativo Android. Ninguna otra aplicación de tu teléfono tiene acceso a esta base de datos a menos que tu dispositivo haya sido rooteado o comprometido externamente.

### 3. Mecanismo de Seguridad por PIN
Pillatelo incluye una opción para establecer un código PIN de 4 dígitos. La validación se ejecuta de forma 100% local mediante algoritmos criptográficos (*hashing*). Si olvidas tu PIN, la aplicación no almacena copias de recuperación en la nube por motivos de estricta privacidad.

### 4. Permisos del Dispositivo
Pillatelo solicita únicamente permisos indispensables para sus funciones específicas:
- **Notificaciones (`POST_NOTIFICATIONS`):** Para mostrar recordatorios programados en tu propio dispositivo (fechas de vencimiento de deudas o alertas de presupuestos).
- **Almacenamiento / Compartir archivos:** Únicamente activo cuando el usuario solicita voluntariamente generar un archivo exportable en **PDF** o **CSV**, permitiéndole compartirlo a través de la hoja de compartir nativa del sistema operativo.

### 5. Control, Respaldo y Eliminación de Datos
- **Eliminación individual:** Puedes borrar cuentas, movimientos, metas o presupuestos de manera individual en cualquier momento.
- **Borrado total:** Puedes limpiar toda la base de datos de la aplicación accediendo a *Ajustes de Android > Aplicaciones > Pillatelo > Almacenamiento > Borrar datos*.
- **Desinstalación:** Al desinstalar la app, el sistema operativo Android elimina de forma inmediata e irreversible la base de datos local y todos los archivos temporales generados.

### 6. Cumplimiento con Google Play Console (Data Safety)
Para la sección de **Seguridad de los Datos** en Google Play Console:
- ¿La app recopila o comparte datos de usuarios? **NO**.
- ¿Todos los datos recopilados por la app se gestionan localmente en el dispositivo? **SÍ**.
- ¿La app permite la eliminación de datos solicitada por el usuario? **SÍ** (a través de la desinstalación o borrado de datos locales).

### 7. Cambios a esta Política
Cualquier cambio futuro será notificado a través de una actualización de la aplicación y reflejado en este documento con su respectiva fecha de revisión.

### 8. Contacto
Si tienes preguntas o inquietudes sobre esta política de privacidad, puedes contactar al desarrollador:
- **Correo electrónico:** amilcar.yujra@gmail.com
