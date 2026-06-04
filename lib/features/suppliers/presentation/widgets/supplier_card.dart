import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/supplier.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final double weekTotal;
  const SupplierCard({super.key, required this.supplier, required this.weekTotal});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: supplier.isActive ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/suppliers/details/${supplier.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: supplier.isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.divider, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(MilkDateUtils.toArabicNumerals(supplier.routeOrder), style: TextStyle(fontWeight: FontWeight.bold, color: supplier.isActive ? AppColors.primary : AppColors.textSecondary, fontSize: 13))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (!supplier.isActive) ...[
                          const SizedBox(width: 6),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)), child: Text('inactive'.tr(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))),
                        ],
                      ]),
                      if (supplier.village != null) Row(children: [Image.asset(AssetPaths.iconPin, width: 10, height: 10), const SizedBox(width: 4), Text(supplier.village!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))]),
                      if (supplier.phone != null) Row(children: [Image.asset(AssetPaths.iconPhone, width: 10, height: 10), const SizedBox(width: 4), Text(supplier.phone!, textDirection: TextDirection.ltr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('this_week'.tr(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('${MilkDateUtils.toArabicNumeralsStr(weekTotal.toStringAsFixed(1))} ${'unit_kg'.tr()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: supplier.isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.divider, borderRadius: BorderRadius.circular(4)),
                      child: Text(supplier.isActive ? 'active'.tr() : 'inactive'.tr(), style: TextStyle(fontSize: 10, color: supplier.isActive ? AppColors.primary : AppColors.textSecondary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
