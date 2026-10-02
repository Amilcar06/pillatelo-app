import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../data/categoria_model.dart';
import '../viewmodel/configuracion_viewmodel.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfiguracionViewModel>().cargarCategorias();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _mostrarModalAgregarCategoria(BuildContext context) {
    final nombreController = TextEditingController();
    String tipoSeleccionado = 'gasto';
    String colorSeleccionado = '#EF4444';

    final coloresDisponibles = [
      '#EF4444', '#F59E0B', '#10B981', '#3B82F6',
      '#6366F1', '#8B5CF6', '#EC4899', '#64748B',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nueva Categoría',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la categoría',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'gasto', label: Text('Gasto')),
                  ButtonSegment(value: 'ingreso', label: Text('Ingreso')),
                ],
                selected: {tipoSeleccionado},
                onSelectionChanged: (val) {
                  setModalState(() {
                    tipoSeleccionado = val.first;
                    colorSeleccionado = val.first == 'gasto' ? '#EF4444' : '#10B981';
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Color:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: coloresDisponibles.map((colorHex) {
                  final colorInt = int.parse(colorHex.replaceAll('#', 'FF'), radix: 16);
                  final isSelected = colorSeleccionado == colorHex;

                  return GestureDetector(
                    onTap: () => setModalState(() => colorSeleccionado = colorHex),
                    child: CircleAvatar(
                      backgroundColor: Color(colorInt),
                      radius: isSelected ? 18 : 14,
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final nombre = nombreController.text.trim();
                    if (nombre.isEmpty) return;

                    final nuevaCat = Categoria(
                      nombre: nombre,
                      tipo: tipoSeleccionado,
                      color: colorSeleccionado,
                    );

                    final configVm = context.read<ConfiguracionViewModel>();
                    await configVm.agregarCategoria(nuevaCat);

                    if (context.mounted) {
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Guardar Categoría'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConfiguracionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Categorías'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Gastos (${vm.gastos.length})'),
            Tab(text: 'Ingresos (${vm.ingresos.length})'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListaCategorias(context, vm.gastos),
                _buildListaCategorias(context, vm.ingresos),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarModalAgregarCategoria(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListaCategorias(BuildContext context, List<Categoria> categorias) {
    if (categorias.isEmpty) {
      return const Center(child: Text('Sin categorías registradas'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categorias.length,
      itemBuilder: (ctx, i) {
        final cat = categorias[i];
        final colorHex = cat.color;
        final colorInt = int.parse(colorHex.replaceAll('#', 'FF'), radix: 16);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(colorInt),
              radius: 14,
            ),
            title: Text(cat.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: cat.isDefault ? const Text('Predeterminada', style: TextStyle(fontSize: 12)) : null,
            trailing: cat.isDefault
                ? null
                : IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.gasto),
                    onPressed: () async {
                      if (cat.id != null) {
                        await context.read<ConfiguracionViewModel>().eliminarCategoria(cat.id!);
                      }
                    },
                  ),
          ),
        );
      },
    );
  }
}
