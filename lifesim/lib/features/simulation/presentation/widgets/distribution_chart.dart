import 'package:flutter/material.dart';

import '../../domain/simulation_result.dart';

/// Histograma de la distribución de resultados de una simulación.
///
/// Cada barra es un rango de resultados; su altura indica cuántas
/// simulaciones cayeron ahí. La barra que contiene el promedio se resalta.
/// No usa paquetes externos.
class DistributionChart extends StatelessWidget {
  final List<HistogramBin> bins;
  final double mean;

  /// Cómo mostrar un número (por ejemplo, con separador de miles).
  final String Function(double value) format;

  final double height;

  const DistributionChart({
    super.key,
    required this.bins,
    required this.mean,
    required this.format,
    this.height = 190,
  });

  int _meanIndex() {
    for (var i = 0; i < bins.length; i++) {
      if (mean < bins[i].to) return i;
    }
    return bins.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final total = bins.fold<int>(0, (sum, b) => sum + b.count);
    final maxCount = bins.fold<int>(0, (m, b) => b.count > m ? b.count : m);

    if (bins.isEmpty || total == 0 || maxCount == 0) {
      return const SizedBox.shrink();
    }

    final color = Theme.of(context).colorScheme.primary;
    final meanIndex = _meanIndex();
    final maxBarHeight = height - 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < bins.length; i++)
                Expanded(
                  child: Tooltip(
                    message:
                        '${format(bins[i].from)} a ${format(bins[i].to)}\n'
                        '${bins[i].count} simulaciones '
                        '(${(bins[i].count / total * 100).toStringAsFixed(1)}%)',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${(bins[i].count / total * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: bins[i].count == 0
                                ? 0
                                : (maxBarHeight * bins[i].count / maxCount)
                                    .clamp(2.0, maxBarHeight),
                            decoration: BoxDecoration(
                              color: i == meanIndex
                                  ? color
                                  : color.withValues(alpha: 0.35),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              format(bins.first.from),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              format(bins.last.to),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Rango donde cae el promedio (${format(mean)})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }
}