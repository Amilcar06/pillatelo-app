# Reglas del Proyecto: Gestión Financiera Personal (Flutter)

## Estándares de UI & UX
- **Radios y Bordes:** Estandarizar todas las tarjetas (`CardTheme`), modales (`BottomSheet`), inputs y contenedores a **16px** (`AppColors.radiusMd`).
- **Navegación:** Usar la estructura principal `MainShell` basada en `NavigationBar` (Material 3) con indicador Accent (`#6366F1`).
- **Botones de Acción (FAB):** Mantener un único `+` flotante central en el `MainShell` que despliega el `AccionRapidaSheet` para creación de ítems. Evitar FABs individuales por pantalla.
- **Animaciones:** Preferir `TweenAnimationBuilder` para contadores numéricos de saldo y `flutter_animate` para listas/modales escalonados.

## Calidad de Código y Flutter 3.7+
- **Guardas Asíncronas:** Siempre usar `if (!context.mounted) return;` en lugar de `if (!mounted) return;` antes de operaciones con `Navigator` o `ScaffoldMessenger` tras invocaciones `async`.
- **Estructuras de Control:** Envolver siempre las sentencias `if / else` en bloques con llaves `{}` para cumplir con las reglas de lint del proyecto.
