import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import '../asset_paths.dart';
import '../utils/date_utils.dart';

class AbsenceBadge extends StatelessWidget {
  final int days;
  const AbsenceBadge({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.alertBg,
        border: Border.all(color: AppColors.alertLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AssetPaths.iconWarning, width: 12, height: 12),
          const SizedBox(width: 4),
          Text(
            days == 7 ? 'absent_week'.tr() : 'absent_since'.tr(args: [MilkDateUtils.toArabicNumerals(days)]),
            style: const TextStyle(fontSize: 11, color: AppColors.alert, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
