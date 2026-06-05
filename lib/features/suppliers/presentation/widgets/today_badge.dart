import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/milk_entry.dart';

class TodayBadge extends StatelessWidget {
  final MilkEntry? entry;
  const TodayBadge({super.key, this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppColors.alertBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.alertLight)),
        child: Text('not_recorded_today'.tr(), style: const TextStyle(color: AppColors.alert, fontSize: 12)),
      );
    }
    if (entry!.entryStatus == EntryStatus.noMilk) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppColors.noMilkBg, borderRadius: BorderRadius.circular(10)),
        child: Text('no_milk_label'.tr(), style: const TextStyle(color: AppColors.noMilk, fontSize: 12)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(
        'kg_today'.tr(args: [MilkDateUtils.toArabicNumeralsStr((entry!.currentWeightKg ?? 0).toStringAsFixed(1))]),
        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
