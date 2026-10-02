import 'package:flutter/material.dart';

/// Widget reutilizable que protege los formularios contra la pérdida
/// accidental de datos al presionar el botón "Atrás".
/// 
/// Envuelve la pantalla de formulario y muestra un diálogo de
/// confirmación si [hasUnsavedChanges] es `true`.
class DiscardGuard extends StatelessWidget {
  final bool hasUnsavedChanges;
  final Widget child;

  const DiscardGuard({
    super.key,
    required this.hasUnsavedChanges,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }

  Future<bool> _showDiscardDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 10),
            Expanded(child: Text('¿Descartar cambios?')),
          ],
        ),
        content: const Text(
          'Si sales ahora perderás los datos que has ingresado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Seguir editando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    ) ?? false;
  }
}
