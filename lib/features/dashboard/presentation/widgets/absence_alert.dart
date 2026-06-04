import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../../../../core/utils/date_utils.dart';

class AbsenceAlert extends StatelessWidget {
  final int count;
  const AbsenceAlert({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.alertBg, borderRadius: BorderRadius.circular(12), border: const Border(right: BorderSide(color: AppColors.alert, width: 4))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(AssetPaths.iconWarning, width: 20, height: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('absence_warning_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.alert, fontSize: 13)),
              const SizedBox(height: 2),
              Text('absence_warning_body'.tr(args: [MilkDateUtils.toArabicNumerals(count)]), style: const TextStyle(color: AppColors.alert, fontSize: 12)),
              GestureDetector(onTap: () => context.go('/suppliers'), child: Text('view_suppliers'.tr(), style: const TextStyle(color: AppColors.alert, fontSize: 12, decoration: TextDecoration.underline, fontWeight: FontWeight.w600))),
            ],
          )),
        ],
      ),
    );
  }
}
