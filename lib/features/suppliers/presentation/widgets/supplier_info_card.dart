import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';
import 'today_badge.dart';

class SupplierInfoCard extends StatelessWidget {
  final Supplier supplier;
  final MilkEntry? todayEntry;
  const SupplierInfoCard({super.key, required this.supplier, this.todayEntry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (supplier.village != null) Row(children: [Image.asset(AssetPaths.iconPin, width: 12, height: 12), const SizedBox(width: 4), Text(supplier.village!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))]),
                    if (supplier.phone != null)
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('tel:${supplier.phone}')),
                        child: Row(children: [Image.asset(AssetPaths.iconPhone, width: 12, height: 12), const SizedBox(width: 4), Text(supplier.phone!, textDirection: TextDirection.ltr, style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline, fontSize: 13))]),
                      ),
                  ],
                ),
              ),
              TodayBadge(entry: todayEntry),
            ],
          ),
          if (!supplier.isActive) ...[
            const SizedBox(height: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(8)), child: const Text('غير نشط', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
          ],
        ],
      ),
    );
  }
}
