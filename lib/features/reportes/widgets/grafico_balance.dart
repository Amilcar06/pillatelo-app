import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class GraficoBalance extends StatelessWidget {
  final double ingresos;
  final double egresos;

  const GraficoBalance({
    super.key,
    required this.ingresos,
    required this.egresos,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = (ingresos > egresos ? ingresos : egresos);
    final maxY = maxVal == 0 ? 100.0 : maxVal * 1.2;

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Ingresos', style: TextStyle(color: AppColors.ingreso, fontWeight: FontWeight.bold)),
                      );
                    case 1:
                      return const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Gastos', style: TextStyle(color: AppColors.gasto, fontWeight: FontWeight.bold)),
                      );
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: ingresos,
                  color: AppColors.ingreso,
                  width: 32,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: egresos,
                  color: AppColors.gasto,
                  width: 32,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
