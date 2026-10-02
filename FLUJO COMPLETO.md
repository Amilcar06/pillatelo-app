# **FLUJO COMPLETO DE LA APLICACIÓN**

---

## 🔹 FASE 0: Primer inicio / Setup inicial

**Objetivo:** configurar la base contable y preferencias del usuario para comenzar el control financiero. 

```
/setup
 ├── /setup/bienvenida
 │     • Pantalla de presentación (logo, nombre de la app, propósito)
 │     • Botón “Comenzar configuración”
 │
 ├── /setup/saldo-inicial
 │     • Campos:
 │         - Saldo en efectivo actual (obligatorio)
 │         - Saldo en banco (opcional)
 │         - Nota y fecha
 │     • Botones: [Continuar] [Omitir]
 │     • Guarda registro inicial (base del balance)
 │
 ├── /setup/pin
 │     • Configurar PIN de acceso (4 o 6 dígitos)
 │     • Confirmar PIN
 │     • Guarda el PIN cifrado en almacenamiento seguro
 │
 ├── /setup/preferencias
 │     • Selección de moneda principal (BOB, USD, etc.)
 │     • Tema: claro / oscuro
 │     • Activar sincronización con Firebase (opcional)
 │     • Crear primera categoría o movimiento inicial (opcional)
 │     • Botón “Finalizar configuración”
 │
 └── /inicio   → entra al dashboard principal

```

---

## 🔹 FASE 1: Pantalla principal / Dashboard general

**Ruta:** `/inicio`

**Objetivo:** mostrar el estado financiero actual del usuario de forma resumida.

### Contenido:

- Fecha y saludo del día.
- **Resumen de balances:**
    - Saldo total actual (efectivo + banco)
    - Total ingresos del mes
    - Total egresos del mes
- **Últimos movimientos** (lista compacta).
- **Progreso de metas** (si existen metas activas).
- Botón flotante ➕ → acceso a “Registro rápido”.

### Acciones:

- Ver todos los movimientos → `/movimientos`
- Crear nuevo movimiento → `/movimientos/registrar`
- Ver detalles de meta → `/metas`
- Acceso al menú inferior para navegación global.

---

## 🔹 FASE 2: Movimientos (Ingresos / Egresos)

**Ruta principal:** `/movimientos`

```
/movimientos
 ├── /movimientos/lista
 │     • Lista general de movimientos (tipo, categoría, monto, fecha)
 │     • Filtros:
 │         - Por tipo (Ingreso / Gasto)
 │         - Por categoría
 │         - Por rango de fechas
 │     • Buscador por descripción o monto
 │     • Botón flotante: “Nuevo movimiento”
 │
 ├── /movimientos/registrar
 │     • Campos:
 │         - Tipo: Ingreso | Gasto
 │         - Monto
 │         - Descripción
 │         - Categoría (selector o crear nueva)
 │         - Método: Efectivo / Tarjeta / Banco
 │         - Fecha (por defecto hoy)
 │     • Botones: Guardar / Cancelar
 │     • Guarda localmente y sincroniza con Firebase (si habilitado)
 │
 └── /movimientos/rapido (modal)
        • Campos mínimos:
            - Tipo (Ingreso/Gasto)
            - Monto
            - Descripción rápida
        • Se guarda automáticamente con categoría “General”.

```

---

## 🔹 FASE 3: Préstamos y Deudas

**Ruta principal:** `/prestamos`

```
/prestamos
 ├── /prestamos/lista
 │     • Tabs:
 │         - “Prestados por mí”
 │         - “Recibidos de otros”
 │     • Cada elemento muestra:
 │         - Persona, monto, fecha préstamo, devolución, estado.
 │     • Filtros:
 │         - Activos / Saldados
 │     • Ícono de recordatorio si la devolución está próxima.
 │     • Botón flotante: “Registrar préstamo”
 │
 ├── /prestamos/registrar
 │     • Campos:
 │         - Tipo: Prestado | Recibido
 │         - Persona
 │         - Monto
 │         - Fecha de préstamo
 │         - Fecha de devolución (opcional)
 │         - Interés (% opcional)
 │         - Notas
 │     • Botones: Guardar / Cancelar
 │
 └── /prestamos/detalle/:id
        • Información completa del préstamo
        • Botones:
            - “Marcar como saldado”
            - “Editar información”
            - “Eliminar registro”

```

---

## 🔹 FASE 4: Metas financieras

**Ruta principal:** `/metas`

```
/metas
 ├── /metas/lista
 │     • Muestra metas activas y completadas
 │     • Elementos:
 │         - Nombre, monto objetivo, monto actual
 │         - Barra de progreso (%)
 │     • Botón flotante: “Nueva meta”
 │
 ├── /metas/registrar
 │     • Campos:
 │         - Nombre de la meta
 │         - Monto objetivo
 │         - Fecha límite (opcional)
 │         - Aporte inicial
 │         - Aporte periódico (mensual/semanal)
 │     • Botón: Guardar
 │
 ├── /metas/detalle/:id
 │     • Información detallada de la meta
 │     • Barra de progreso animada
 │     • Botones:
 │         - Añadir aporte manual
 │         - Editar meta
 │         - Marcar como completada
 │
 └── /metas/ajustes
        • Opcional: configuración de recordatorios o sugerencias de ahorro.

```

---

## 🔹 FASE 5: Reportes y análisis

**Ruta:** `/reportes`

```
/reportes
 ├── /reportes/vista
 │     • Selector de rango:
 │         - Semana | Mes | Año | Personalizado
 │     • Métricas:
 │         - Total ingresos
 │         - Total egresos
 │         - Balance general
 │         - Categoría con mayor gasto
 │     • Gráfico de barras: ingresos vs egresos
 │     • Texto de tendencia: “Gastaste 15% más en transporte que el mes pasado”
 │     • Botón: “Exportar PDF”
 │
 └── /reportes/pdf
        • Vista previa del PDF generado
        • Botones: Descargar / Compartir

```

---

## 🔹 FASE 6: Configuración y cuenta

**Ruta:** `/configuracion`

```
/configuracion
 ├── /configuracion/cuenta
 │     • Ver nombre de usuario
 │     • Cambiar PIN
 │     • Reiniciar datos (solo local)
 │
 ├── /configuracion/sincronizacion
 │     • Sincronizar con Firebase (manual)
 │     • Mostrar fecha del último respaldo automático
 │
 ├── /configuracion/saldos
 │     • Ver saldos actuales (efectivo / banco)
 │     • Editar o recalibrar saldo base
 │
 ├── /configuracion/categorias
 │     • Lista de categorías personalizadas
 │     • Botones: Añadir, editar, eliminar
 │
 ├── /configuracion/preferencias
 │     • Tema: Claro / Oscuro
 │     • Moneda predeterminada
 │     • Notificaciones: activar/desactivar recordatorios
 │
 └── /configuracion/acerca
        • Información de la app
        • Versión, desarrollador, contacto

```

---

## 🔹 FASE 7: Seguridad y autenticación

```
/pin
  • Campo de ingreso del PIN (teclado numérico)
  • Validación local con almacenamiento seguro
  • Redirección a /inicio si es correcto
  • Bloqueo automático tras X minutos de inactividad

```

---

## 🔹 FASE 8: Flujo técnico de datos (offline / online)

```
1. Usuario registra o edita un dato → guardado en SQLite local.
2. Si la sincronización está activa y hay conexión → se sube a Firebase.
3. Firebase almacena datos por usuario (UID).
4. Al abrir la app:
     - Carga local primero (modo offline).
     - Luego sincroniza los cambios pendientes.
5. Reportes y balances se calculan localmente.
6. PDFs se generan localmente y se pueden guardar en memoria o subir a Drive (opcional).

```

---

## 🔹 FASE 9: Notificaciones

- **Locales:**
    - Recordatorios de préstamos pendientes.
    - Alertas de metas próximas a vencerse.
    - Resúmenes automáticos (semanales o mensuales).
- **Push (opcional, si se usa Firebase):**
    - Sincronización confirmada.
    - Respaldo exitoso.

---

## 🔁 Flujo general resumido

```
/setup
   ↓
/pin
   ↓
/inicio
   ├── /movimientos
   ├── /prestamos
   ├── /metas
   ├── /reportes
   └── /configuracion

```

---

## 🔮 FASE FUTURA (versión ampliada)

- Multiples cuentas (efectivo, banco, tarjeta).
- Transferencias internas entre cuentas.
- Dashboard anual comparativo.
- Sincronización entre dispositivos (web/móvil).
- AI financiera para recomendaciones automáticas.

---