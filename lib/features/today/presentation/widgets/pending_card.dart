import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';

class PendingCard extends StatelessWidget {
  final Supplier supplier;
  final MilkEntry? entry;
  final bool isLocked;
  final VoidCallback? onWeightEntry;
  final VoidCallback? onNoMilk;
  const PendingCard({super.key, required this.supplier, this.entry, this.isLocked = false, this.onWeightEntry, this.onNoMilk});

  @override
  Widget build(BuildContext context) {
    final isNoMilk = entry?.entryStatus == EntryStatus.noMilk;
    final isRecorded = entry?.entryStatus == EntryStatus.recorded;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: entry != null ? () => context.push('/entry/${entry!.id}') : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            _routeOrder(supplier.routeOrder),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              if (supplier.village != null) Text(supplier.village!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ])),
            if (isRecorded) _recordedBadge(),
            if (isNoMilk) _noMilkBadge(),
            if (!isRecorded && !isNoMilk) _actions(),
          ]),
        ),
      ),
    );
  }

  Widget _routeOrder(int order) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
    child: Center(child: Text(MilkDateUtils.toArabicNumerals(order), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13))),
  );

  Widget _recordedBadge() {
    final kg = entry!.currentWeightKg?.toStringAsFixed(1) ?? '0';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text('${MilkDateUtils.toArabicNumeralsStr(kg)} ${'unit_kg'.tr()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _noMilkBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.noMilkBg, borderRadius: BorderRadius.circular(12)),
    child: Text('no_milk'.tr(), style: const TextStyle(color: AppColors.noMilk, fontWeight: FontWeight.bold, fontSize: 12)),
  );

  Widget _actions() {
    if (isLocked) return const Icon(Icons.lock, size: 18, color: AppColors.textHint);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _actionBtn('enter_weight'.tr(), AppColors.primary, onWeightEntry),
      const SizedBox(width: 6),
      _actionBtn('no_milk'.tr(), AppColors.noMilk, onNoMilk),
    ]);
  }

  Widget _actionBtn(String label, Color color, VoidCallback? onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    ),
  );
}
