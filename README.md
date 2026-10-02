# Aplicación de Gestión Financiera Personal

Aplicación móvil construida en **Flutter** para el control integral de finanzas personales: registro ágil de ingresos y gastos, gestión multi-cuenta bancaria con colores personalizados, préstamos y deudas con amortización, metas de ahorro, presupuestos y reportes gráficos.

---

## 🌟 Características Principales

1. **Dashboard Financiero Central (`InicioPage`)**
   - **Saldo Total Unificado:** Suma dinámica en tiempo real de todos los fondos disponibles en efectivo, cuentas bancarias y billeteras móviles.
   - **Métricas del Mes en Curso:** Visualización clara de los ingresos y egresos correspondientes al mes calendario actual.
   - **Modo Ojo (Privacidad):** Alterna la visibilidad de saldos y números (`Bs. ••••••`) con un toque para evitar miradas indiscretas en público.

2. **Captura Rápida de Dinero (Ultra Ágil / Cero Fricción)**
   - Tarjeta interactiva en la pantalla principal para registrar movimientos inmediatamente.
   - Presets rápidos de monto (+10, +20, +50, +100 Bs.) y botones directos **[+ Ingreso]** y **[- Gasto]**.
   - Asignación inteligente: si existe una sola cuenta, se guarda en 1 toque como registro rápido; si hay múltiples cuentas, despliega un selector inmediato de 1 clic.

3. **Multi-Cuentas Bancarias con Colores Personalizados**
   - Agrupación visual de bancos bolivianos (Banco Unión, BNB, BCP, Bisa, Mercantil, Fie, etc.), billeteras digitales (Yape, Tigo Money) y Efectivo.
   - **Paleta extendida de 14 colores fintech** para identificar cada cuenta fácilmente.
   - **Edición interactiva:** Toca cualquier tarjeta bancaria en el inicio para modificar su nombre, saldo o color distintivo.

4. **Control de Préstamos y Deudas con Amortización**
   - Gestión dividida en **Me Deben** (préstamos otorgados) y **Debo** (préstamos recibidos).
   - Registro de abonos/devoluciones parciales con historial detallado y amortización automática de la deuda.
   - Impacto directo opcional en el saldo de la cuenta bancaria seleccionada.

5. **Metas y Presupuestos**
   - Metas de ahorro con barra de progreso porcentual y registro de aportes.
   - Presupuestos mensuales por categoría de gasto con alertas de límite.

6. **Automatización y Reportes**
   - Motor de transacciones recurrentes automáticas (sueldos, alquileres, suscripciones).
   - Reportes estadísticos interactivos con gráficos circulares y barras (`fl_chart`).
   - Exportación de estados financieros a **PDF profesional** y archivos **CSV**.

7. **Seguridad Integrada**
   - Bloqueo de la aplicación mediante **PIN de seguridad** con teclado numérico numérico háptico (`numeric_keypad`).

---

## 📐 Fórmulas Matemáticas y Reglas Contables

### 1. Saldo Total Unificado
El balance general de la pantalla principal no es un número arbitrario, sino la suma real de todos los balances de cuentas activas en la base de datos:
$$\text{Saldo Total Unificado} = \sum_{i=1}^{n} \text{Cuenta}_i.\text{saldoActual} \quad (\forall \, \text{is\_deleted} = 0)$$

### 2. Conciliación de Movimientos (Deltas en Cuenta)
Al registrar o eliminar un ingreso o egreso vinculado a una cuenta:
- **Al Insertar:**
  $$\Delta = \begin{cases} +\text{Monto}, & \text{si tipo} = \text{'ingreso'} \\ -\text{Monto}, & \text{si tipo} = \text{'gasto'} \end{cases}$$
  $$\text{Cuenta}.\text{saldoActual} = \text{Cuenta}.\text{saldoActual} + \Delta$$
- **Al Eliminar:** Se invierte automáticamente el delta ($\text{saldoActual} = \text{saldoActual} - \Delta$).

### 3. Métricas Mensuales vs. Históricas
Para evitar que ingresos o gastos de meses pasados distorsionen la salud financiera del periodo actual, las tarjetas superiores del Dashboard calculan:
$$\text{Total Ingresos (Mes)} = \sum \text{Movimiento}.\text{monto} \quad (\text{tipo} = \text{'ingreso'} \land \text{mes} = \text{mes\_actual} \land \text{año} = \text{año\_actual})$$
$$\text{Total Gastos (Mes)} = \sum \text{Movimiento}.\text{monto} \quad (\text{tipo} = \text{'gasto'} \land \text{mes} = \text{mes\_actual} \land \text{año} = \text{año\_actual})$$

### 4. Ciclo de Vida Contable de Préstamos y Devoluciones
| Operación | Tipo Préstamo | Efecto en Cuenta Origen | Deuda Restante (`remaining_amount`) |
|---|---|---|---|
| **Crear Préstamo** | `prestado` (Me deben) | $-\text{Monto}$ (sale de mi cuenta) | Inicial: $\text{Monto}$ |
| **Crear Préstamo** | `recibido` (Yo debo) | $+\text{Monto}$ (entra a mi cuenta) | Inicial: $\text{Monto}$ |
| **Abono Parcial** | `prestado` | $+\text{Abono}$ (me pagan, entra) | $\text{Restante} - \text{Abono}$ |
| **Abono Parcial** | `recibido` | $-\text{Abono}$ (pago mi deuda, sale) | $\text{Restante} - \text{Abono}$ |
| **Eliminar Préstamo** | Cualquiera | **Reversión completa:** Se deshacen todos los abonos y el desembolso inicial atómicamente en SQL. | Eliminado |

---

## 🎨 Estándares de Diseño y UI/UX

- **Filosofía Visual:** Paleta **Slate Dark** (`#0F172A`) & **Indigo Minimal** (`#6366F1`) para un aspecto fintech premium.
- **Tipografía:** [Outfit de Google Fonts](https://fonts.google.com/specimen/Outfit) configurada globalmente.
- **Geometría Unificada:** Todas las tarjetas (`CardTheme`), modales (`BottomSheet`) e inputs siguen un radio de curvatura de **16px** (`AppColors.radiusMd`).
- **Navegación:** `MainShell` con Material 3 `NavigationBar` y un único **Floating Action Button (`+`)** central que despliega `AccionRapidaSheet`.

---

## 🛠️ Stack Tecnológico y Dependencias

- **Framework:** Flutter 3.7+ (Dart 3.7)
- **Gestión de Estado:** `provider: ^6.1.2`
- **Inyección de Dependencias:** `get_it: ^9.2.1`
- **Navegación:** `go_router: ^14.2.3`
- **Persistencia Local:** `sqflite: ^2.4.2` + `shared_preferences`
- **Tipografía y Gráficos:** `google_fonts: ^6.2.1`, `fl_chart: ^0.69.0`
- **Animaciones y Estilo:** `flutter_animate: ^4.5.0`
- **Exportación:** `pdf: ^3.11.3`, `csv: ^6.0.0`, `share_plus: ^12.0.2`

---

## 🚀 Guía de Instalación y Ejecución

1. **Clonar el repositorio:**
   ```bash
   git clone <url-del-repositorio>
   cd "PROYECTO APP"
   ```

2. **Instalar paquetes:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar pruebas automatizadas:**
   ```bash
   flutter test
   ```

4. **Lanzar la aplicación:**
   ```bash
   flutter run
   ```
