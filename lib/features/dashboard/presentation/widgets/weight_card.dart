import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/date_utils.dart';

class WeightCard extends StatelessWidget {
  final String label;
  final double weight;
  final Color color;
  const WeightCard({super.key, required this.label, required this.weight, required this.color});

  @override
  Widget build(BuildContext context) {
    final display = weight % 1 == 0
        ? MilkDateUtils.toArabicNumerals(weight.toInt())
        : MilkDateUtils.toArabicNumeralsStr(weight.toStringAsFixed(1));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
          const SizedBox(height: 4),
          Text('$display ${'unit_kg'.tr()}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
