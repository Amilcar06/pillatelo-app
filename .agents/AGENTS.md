# Guía y Reglas del Proyecto: Pillatelo (Gestión Financiera Personal)

## 📌 1. Filosofía y Arquitectura
- **Privacidad y Offline-First:** Los datos financieros del usuario residen 100% de forma local en SQLite (`sqflite`). No incorporar servicios en la nube o analíticas externas sin consentimiento explícito.
- **Estructura por Capas:**
  - **UI / Páginas / Modales:** Consumen estado con `context.watch<T>()` o `Consumer<T>`.
  - **ViewModels (`ChangeNotifier`):** Manejan la lógica de presentación y notifican cambios (`notifyListeners`).
  - **Repositories & DAOs:** Encapsulan el acceso a SQLite (`BaseRepository` y DAOs específicos).
  - **Inyección de Dependencias:** Usar `locator` (`get_it`) para resolver repositorios y servicios.
- **Sincronización:** Cuando un movimiento o préstamo afecte el saldo de una cuenta o el widget de inicio, actualizar automáticamente `CuentaViewModel` y `HomeWidgetService`.

---

## 🎨 2. Estándares de UI & UX (Material Design 3)
- **Radios y Bordes:** Estandarizar tarjetas (`CardTheme`), modales (`BottomSheet`), inputs y contenedores a **16px** (`AppColors.radiusMd`).
- **Paleta de Colores:** Utilizar exclusivamente `AppColors`:
  - Fondo oscuro / Primario: `AppColors.primary` (`#0F172A` - Slate Dark).
  - Acento: `AppColors.accent` (`#6366F1` - Indigo minimal).
  - Indicadores: `AppColors.ingreso` (`#10B981`), `AppColors.gasto` (`#EF4444`), `AppColors.prestamo` (`#8B5CF6`).
  - No hardcodear colores genéricos (`Colors.red`, `Colors.blue`).
- **Navegación:** Mantener la estructura principal en `MainShell` con `NavigationBar` (M3).
- **Botón de Acción Central (FAB):** Un único botón flotante central en `MainShell` con comportamiento contextual (detecta la pestaña actual o despliega `AccionRapidaSheet`). No crear FABs secundarios individuales por pantalla.
- **Microinteracciones y Feedback:**
  - Usar `HapticFeedback.heavyImpact()` o `selectionClick()` en confirmaciones importantes.
  - Usar `TweenAnimationBuilder` para transiciones numéricas suaves de saldos.
  - Soportar el escalado de fuentes mediante `FontScaleProvider` sin desbordar contenedores (`overflow: TextOverflow.ellipsis` donde corresponda).

---

## 🛡️ 3. Patrones de Interacción Reutilizables
- **Protección contra Pérdida de Datos (`DiscardGuard`):**
  - Todo formulario (creación/edición de movimientos, préstamos, metas, presupuestos, etc.) debe envolver su vista en `DiscardGuard(hasUnsavedChanges: hasData, child: Scaffold(...))`.
  - Preguntar confirmación al usuario antes de salir si ya ha ingresado datos.
- **Notificaciones Estándar (`AppSnackBar`):**
  - No instanciar `SnackBar` directamente con textos planos.
  - Usar `AppSnackBar.showSuccessWithUndo(...)` en altas/modificaciones de registros con reversión de 4 segundos.
  - Usar `AppSnackBar.showSuccess(...)` o `AppSnackBar.showError(...)` para retroalimentación visual clara con iconos redondeados y bordes de 16px.

---

## 💻 4. Calidad de Código y Flutter / Dart
- **Guardas Asíncronas en `State`:**
  - En cualquier subclase de `State<T>`, tras un `await` async, usar siempre:
    ```dart
    if (!mounted || !context.mounted) {
      return;
    }
    ```
  - Evitar invocar `Navigator.pop(context)` antes de usar `context` para un SnackBar (o capturar el `ScaffoldMessenger` antes del pop).
- **Estructuras de Control:** Envolver siempre las sentencias `if / else` en bloques con llaves `{}`. No usar sentencias de una sola línea sin llaves.
- **Verificación Obligatoria:**
  - Todo cambio o nueva funcionalidad debe validarse con:
    ```bash
    flutter analyze  # Debe reportar 0 issues
    flutter test     # Todos los tests deben pasar
    ```

---

## 🚀 5. Control de Versiones y Seguridad
- **Commits Semánticos:** Usar formato estándar (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`).
- **Protección de Secretos:** Nunca incluir en el repositorio llaves de firma (`.jks`), credenciales (`key.properties`) ni rutas de entorno local (`local.properties`).
