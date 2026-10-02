import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/meta_viewmodel.dart';
import '../widgets/meta_card.dart';
import 'detalle_meta_page.dart';
import 'registrar_meta_page.dart';

class MetasPage extends StatefulWidget {
  const MetasPage({super.key});

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MetaViewModel>().cargarMetas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metaVm = context.watch<MetaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas Financieras'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Activas (${metaVm.activas.length})'),
            Tab(text: 'Completadas (${metaVm.completadas.length})'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => metaVm.cargarMetas(),
        child: metaVm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildList(context, metaVm.activas, 'No tienes metas activas aún'),
                  _buildList(context, metaVm.completadas, 'No tienes metas completadas'),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegistrarMetaPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Meta'),
      ),
    );
  }

  Widget _buildList(BuildContext context, List metas, String emptyMsg) {
    if (metas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flag_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: metas.length,
      itemBuilder: (ctx, i) {
        final meta = metas[i];
        return MetaCard(
          meta: meta,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetalleMetaPage(meta: meta)),
            );
          },
        );
      },
    );
  }
}
