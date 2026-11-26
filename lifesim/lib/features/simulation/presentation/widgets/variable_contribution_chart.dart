import 'package:flutter/material.dart';

/// Aporte promedio de una variable al resultado.
/// [value] es positivo si la variable suma y negativo si resta.
class ContributionItem {
  final String name;
  final double value;

  const ContributionItem({required this.name, required this.value});
}

/// Barras horizontales con el aporte de cada variable al resultado
/// promedio: las que suman salen hacia la derecha y las que restan,
/// hacia la izquierda.
class VariableContributionChart extends StatelessWidget {
  final List<ContributionItem> items;

  /// Cómo mostrar un número (por ejemplo, con separador de miles).
  final String Function(double value) format;

  const VariableContributionChart({
    super.key,
    required this.items,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final posMax = items.fold<double>(0, (m, i) => i.value > m ? i.value : m);
    final negMax = items.fold<double>(0, (m, i) => -i.value > m ? -i.value : m);

    if (items.isEmpty || posMax + negMax == 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final scale = width / (posMax + negMax);
        final zeroX = negMax * scale;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${item.value < 0 ? '-' : '+'}${format(item.value.abs())}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.value < 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: width,
                height: 18,
                child: Stack(
                  children: [
                    // línea del cero
                    Positioned(
                      left: zeroX - 0.5,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: Colors.grey.withValues(alpha: 0.6),
                      ),
                    ),
                    if (item.value != 0)
                      Positioned(
                        left: item.value > 0 ? zeroX : zeroX + item.value * scale,
                        top: 3,
                        bottom: 3,
                        child: Container(
                          width: (item.value.abs() * scale).clamp(2.0, width),
                          decoration: BoxDecoration(
                            color: item.value < 0
                                ? Colors.red.withValues(alpha: 0.6)
                                : Colors.green.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            const Row(
              children: [
                Icon(Icons.square_rounded, size: 12, color: Colors.green),
                SizedBox(width: 6),
                Text(
                  'Suma al resultado',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(width: 16),
                Icon(Icons.square_rounded, size: 12, color: Colors.red),
                SizedBox(width: 6),
                Text(
                  'Resta al resultado',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}