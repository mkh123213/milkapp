import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';

class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final String iconPath;
  final Color bgColor;
  final Color textColor;
  const StatCard({super.key, required this.label, required this.value, required this.iconPath, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Row(children: [
            Image.asset(iconPath, width: 32, height: 32),
            const SizedBox(width: 8),
            Text(MilkDateUtils.toArabicNumerals(value), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
          ]),
        ],
      ),
    );
  }
}
