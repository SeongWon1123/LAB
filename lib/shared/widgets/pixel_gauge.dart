import 'package:flutter/material.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';

class PixelGauge extends StatelessWidget {
  const PixelGauge({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final blocks = (value / 10).round().clamp(0, 10);
    return Semantics(
      label: '$label $value percent',
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(10, (index) {
                return Expanded(
                  child: Container(
                    height: 12,
                    margin: const EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      color: index < blocks ? AppColors.lcdPixelDark : AppColors.lcdYellow,
                      border: Border.all(color: AppColors.lcdPixelDark, width: 1),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
