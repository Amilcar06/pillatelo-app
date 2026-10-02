import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/configuracion/data/configuracion_repository.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/font_scale_provider.dart';
import 'features/recurrentes/services/recurrente_executor.dart';
import 'core/di/locator.dart';
import 'shared/services/home_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dependency Injection
  setupLocator();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  final fontScaleProvider = FontScaleProvider();
  await fontScaleProvider.init();

  // Inicializar widget de pantalla de inicio
  await HomeWidgetService.init();
  
  runApp(MyApp(themeProvider: themeProvider, fontScaleProvider: fontScaleProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final FontScaleProvider fontScaleProvider;
  
  const MyApp({super.key, required this.themeProvider, required this.fontScaleProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<FontScaleProvider>.value(value: fontScaleProvider),
        ...appProviders,
      ],
      child: Consumer2<ThemeProvider, FontScaleProvider>(
        builder: (context, theme, fontScale, child) {
          return MaterialApp(
            title: 'Pillatelo: Finanzas y Gastos',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            debugShowCheckedModeBanner: false,
            routes: AppRouter.routes,
            home: const _StartGate(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(fontScale.scale),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class _StartGate extends StatefulWidget {
  const _StartGate();
  @override
  State<_StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<_StartGate> {
  final _configRepo = ConfiguracionRepository();

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final cfg = await _configRepo.get();
    
    // Ejecutar recurrentes pendientes
    await RecurrenteExecutor.ejecutarPendientes();

    if (!mounted || !context.mounted) {
      return;
    }

    final hasCompleted = cfg.setupComplete;
    if (!hasCompleted) {
      Navigator.pushReplacementNamed(context, '/setup/bienvenida');
      return;
    }
    final hasPin = (cfg.pin != null && cfg.pin!.isNotEmpty);
    if (hasPin) {
      Navigator.pushReplacementNamed(context, '/pin/login');
    } else {
      Navigator.pushReplacementNamed(context, '/inicio');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
