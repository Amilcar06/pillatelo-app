import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../inicio/ui/inicio_page.dart';
import '../../movimientos/ui/movimientos_page.dart';
import '../../movimientos/ui/registrar_movimiento_page.dart';
import '../../prestamos/ui/prestamos_page.dart';
import '../../prestamos/ui/registrar_prestamo_page.dart';
import '../../../shared/components/accion_rapida_sheet.dart';
import 'mas_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const InicioPage(),
    const MovimientosPage(),
    const PrestamosPage(),
    const MasPage(),
  ];

  /// Acción contextual del FAB según la pantalla actual.
  void _onFabPressed() {
    HapticFeedback.mediumImpact();

    switch (_currentIndex) {
      case 1: // Movimientos → Registrar Movimiento directo
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegistrarMovimientoPage()),
        );
        break;

      case 2: // Préstamos → Registrar Préstamo directo
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegistrarPrestamoPage()),
        );
        break;

      case 0: // Inicio → AccionRapidaSheet completo
      case 3: // Más → AccionRapidaSheet completo
      default:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const AccionRapidaSheet(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Movimientos',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake),
            label: 'Préstamos',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}
