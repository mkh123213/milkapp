import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatChipWidget extends StatelessWidget {
  final String label;
  final String value;
  const StatChipWidget({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      );
}
