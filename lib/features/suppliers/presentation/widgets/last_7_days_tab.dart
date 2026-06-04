import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';

class Last7DaysTab extends StatelessWidget {
  final Supplier supplier;
  final List<MilkEntry> entries;
  const Last7DaysTab({super.key, required this.supplier, required this.entries});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: i))).reversed.toList();
    final entryMap = {for (final e in entries) e.dateKey: e};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: days.map((d) {
              final key = MilkDateUtils.toDateKey(d);
              final entry = entryMap[key];
              Color color;
              String label;
              if (entry == null) {
                color = AppColors.missing;
                label = '--';
              } else if (entry.entryStatus == EntryStatus.noMilk) {
                color = AppColors.noMilk;
                label = '0';
              } else {
                color = AppColors.primary;
                label = MilkDateUtils.toArabicNumeralsStr((entry.currentWeightKg ?? 0).toStringAsFixed(0));
              }
              return Expanded(
                child: GestureDetector(
                  onTap: entry != null ? () => context.push('/entry/${entry.id}') : null,
                  child: Column(
                    children: [
                      Container(height: 36, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                      const SizedBox(height: 2),
                      Text(MilkDateUtils.toArabicNumerals(d.day), style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ...days.reversed.map((d) {
            final key = MilkDateUtils.toDateKey(d);
            final entry = entryMap[key];
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 2, offset: const Offset(0, 1))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(MilkDateUtils.formatFullArabic(d), style: const TextStyle(fontSize: 13)),
                  entry == null
                      ? const Text('—', style: TextStyle(color: AppColors.textSecondary))
                      : entry.entryStatus == EntryStatus.noMilk
                          ? Text('no_milk_label'.tr(), style: const TextStyle(color: AppColors.noMilk, fontSize: 13))
                          : Text('${MilkDateUtils.toArabicNumeralsStr((entry.currentWeightKg ?? 0).toStringAsFixed(1))} ${'unit_kg'.tr()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
