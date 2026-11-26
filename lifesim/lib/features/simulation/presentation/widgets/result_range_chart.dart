import 'package:flutter/material.dart';

/// Gráfica del rango de resultados de una simulación.
///
/// Una barra va del mínimo al máximo simulado. La zona sombreada es el
/// rango donde cayó el 80% de los casos (percentil 10 a percentil 90) y
/// las marcas indican el promedio, la mediana y el valor base.
class ResultRangeChart extends StatelessWidget {
  final double min;
  final double max;
  final double p10;
  final double p90;
  final double median;
  final double mean;
  final double baseValue;

  /// Cómo mostrar un número (por ejemplo, con separador de miles).
  final String Function(double value) format;

  const ResultRangeChart({
    super.key,
    required this.min,
    required this.max,
    required this.p10,
    required this.p90,
    required this.median,
    required this.mean,
    required this.baseValue,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const medianColor = Colors.teal;
    const baseColor = Colors.orange;
    final span = max - min;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Posición horizontal de un valor dentro de la barra.
        double x(double value) {
          if (span <= 0) return width / 2;
          return ((value - min) / span * width).clamp(0.0, width);
        }

        Widget marker(double value, Color color) {
          final left = (x(value) - 1.5).clamp(0.0, width - 3);
          return Positioned(
            left: left,
            top: 4,
            child: Container(
              width: 3,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }

        Widget legend(String label, Color color) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          );
        }

        final bandLeft = x(p10);
        final bandWidth = (x(p90) - bandLeft).clamp(3.0, width);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width,
              height: 52,
              child: Stack(
                children: [
                  // barra completa: de mínimo a máximo
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 24,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // zona del 80% central
                  Positioned(
                    left: bandLeft,
                    top: 12,
                    child: Container(
                      width: bandWidth,
                      height: 28,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  marker(median, medianColor),
                  marker(baseValue, baseColor),
                  marker(mean, primary),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  format(min),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  format(max),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                legend('Promedio: ${format(mean)}', primary),
                legend('Mediana: ${format(median)}', medianColor),
                legend('Valor base: ${format(baseValue)}', baseColor),
                legend(
                  'Zona sombreada (80% de los casos): '
                  '${format(p10)} a ${format(p90)}',
                  primary.withValues(alpha: 0.3),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}