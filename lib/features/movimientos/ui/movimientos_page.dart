import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/movimiento_viewmodel.dart';
import '../data/movimiento_model.dart';

class MovimientosPage extends StatefulWidget {
  const MovimientosPage({super.key});

  @override
  State<MovimientosPage> createState() => _MovimientosPageState();
}

class _MovimientosPageState extends State<MovimientosPage> {
  String _filtroActual = 'todo'; // 'todo', 'ingreso', 'gasto'
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovimientoViewModel>().cargarMovimientos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MovimientoViewModel>();
    final df = DateFormat('dd/MM/yyyy - HH:mm');

    List<Movimiento> movimientosFiltrados = vm.movimientos;
    if (_filtroActual != 'todo') {
      movimientosFiltrados = movimientosFiltrados.where((m) => m.tipo == _filtroActual).toList();
    }
    if (_searchQuery.isNotEmpty) {
      movimientosFiltrados = movimientosFiltrados.where((m) =>
        m.descripcion.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    if (_dateRange != null) {
      movimientosFiltrados = movimientosFiltrados.where((m) =>
        m.fecha.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
        m.fecha.isBefore(_dateRange!.end.add(const Duration(days: 1)))
      ).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos')),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar movimiento...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () => setState(() => _searchQuery = '')
                    ) 
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),
          
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todo', 'todo'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ingresos', 'ingreso'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Gastos', 'gasto'),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.date_range, size: 18),
                    label: Text(_dateRange == null ? 'Fecha' : '${df.format(_dateRange!.start).substring(0,5)} - ${df.format(_dateRange!.end).substring(0,5)}'),
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDateRange: _dateRange,
                      );
                      if (picked != null) {
                        setState(() => _dateRange = picked);
                      }
                    },
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppColors.radiusSm),
                      side: BorderSide(color: _dateRange != null ? AppColors.accent : AppColors.border),
                    ),
                  ),
                  if (_dateRange != null) ...[
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() => _dateRange = null),
                      backgroundColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusSm),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
          
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : movimientosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text('No hay movimientos', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: movimientosFiltrados.length,
                        itemBuilder: (ctx, i) {
                          final m = movimientosFiltrados[i];
                          final esIngreso = m.tipo == 'ingreso';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (esIngreso ? AppColors.ingreso : AppColors.gasto).withValues(alpha: 0.12),
                                child: Icon(
                                  esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: esIngreso ? AppColors.ingreso : AppColors.gasto,
                                  size: 20,
                                ),
                              ),
                              title: Text(m.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(df.format(m.fecha)),
                              trailing: Text(
                                '${esIngreso ? '+' : '-'} Bs. ${m.monto.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: esIngreso ? AppColors.ingreso : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String valor) {
    final isSelected = _filtroActual == valor;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _filtroActual = valor;
        });
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: AppColors.accent.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accent : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
        side: BorderSide(
          color: isSelected ? AppColors.accent : AppColors.border,
        ),
      ),
    );
  }
}
