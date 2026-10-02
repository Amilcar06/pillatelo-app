import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../features/movimientos/data/movimiento_model.dart';
import '../../features/reportes/viewmodel/reporte_viewmodel.dart';
import '../components/app_snackbar.dart';

class ExportService {
  static Future<void> exportToCSV(List<Movimiento> movimientos, BuildContext context) async {
    try {
      List<List<String>> csvData = [
        ['Fecha', 'Tipo', 'Descripción', 'Monto', 'Categoría ID', 'Método Pago']
      ];

      final df = DateFormat('yyyy-MM-dd HH:mm');
      for (var m in movimientos) {
        csvData.add([
          df.format(m.fecha),
          m.tipo,
          m.descripcion,
          m.monto.toStringAsFixed(2),
          m.categoriaId?.toString() ?? '',
          m.metodoPago,
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/movimientos_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          subject: 'Exportación de Movimientos CSV',
        ),
      );
    } catch (e) {
      debugPrint('Error al exportar CSV: $e');
      if (context.mounted) {
        AppSnackBar.showError(context, 'Error al exportar CSV');
      }
    }
  }

  static Future<void> exportToPDF(ReporteViewModel vm, BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Reporte Financiero', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Métricas (Este mes)'),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  context: ctx,
                  data: <List<String>>[
                    ['Ingresos', 'Gastos', 'Balance'],
                    [
                      'Bs. ${vm.totalIngresos.toStringAsFixed(2)}',
                      'Bs. ${vm.totalEgresos.toStringAsFixed(2)}',
                      'Bs. ${vm.balanceNeto.toStringAsFixed(2)}',
                    ]
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
                ),
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/reporte_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          subject: 'Reporte Financiero PDF',
        ),
      );
    } catch (e) {
      debugPrint('Error al exportar PDF: $e');
      if (context.mounted) {
        AppSnackBar.showError(context, 'Error al exportar PDF');
      }
    }
  }
}
