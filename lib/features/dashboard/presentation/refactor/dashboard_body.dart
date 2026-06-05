import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../../../../core/utils/date_utils.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/weight_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/absence_alert.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final stats = state.stats;
          final today = DateTime.now();
          return RefreshIndicator(
            onRefresh: () async => context.read<DashboardCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(children: [
                      Image.asset(AssetPaths.logo, width: 48, height: 48),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('app_title'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(MilkDateUtils.formatFullArabic(today), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ]),
                    ]),
                    const SizedBox(height: 16),
                    if (state.absentSuppliers.isNotEmpty) ...[AbsenceAlert(count: state.absentSuppliers.length), const SizedBox(height: 12)],
                    Row(children: [
                      Expanded(child: WeightCard(label: 'dashboard_today_weight'.tr(), weight: stats.todayWeight, color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: WeightCard(label: 'dashboard_week_weight'.tr(), weight: stats.weekWeight, color: const Color(0xFF1565C0))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: StatCard(label: 'stat_received'.tr(), value: stats.receivedToday, iconPath: AssetPaths.iconCheck, bgColor: const Color(0xFFE8F5E9), textColor: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(label: 'stat_pending'.tr(), value: stats.pendingToday, iconPath: AssetPaths.iconHourglass, bgColor: const Color(0xFFF5F5F5), textColor: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: StatCard(label: 'stat_no_milk'.tr(), value: stats.noMilkToday, iconPath: AssetPaths.iconZero, bgColor: const Color(0xFFE3F2FD), textColor: AppColors.noMilk)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(label: 'stat_edited'.tr(), value: stats.editedToday, iconPath: AssetPaths.iconPencil, bgColor: const Color(0xFFFFF3E0), textColor: AppColors.edited)),
                    ]),
                    const SizedBox(height: 20),
                    Text('quick_actions'.tr(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => context.go('/today'),
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                        child: Row(children: [
                          Image.asset(AssetPaths.iconClipboard, width: 24, height: 24, color: Colors.white, colorBlendMode: BlendMode.srcATop),
                          const SizedBox(width: 12),
                          Expanded(child: Text('today_title'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                          Text('${MilkDateUtils.toArabicNumerals(stats.receivedToday)}/${MilkDateUtils.toArabicNumerals(stats.totalSuppliers)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_left, color: Colors.white.withValues(alpha: 0.7), size: 20),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _SmallAction(label: 'add_supplier'.tr(), icon: Icons.add, iconColor: AppColors.primary, onTap: () => context.push('/suppliers/add'))),
                      const SizedBox(width: 8),
                      Expanded(child: _SmallAction(label: 'week_reports'.tr(), iconAsset: AssetPaths.iconChart, onTap: () => context.go('/reports'))),
                    ]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final String? iconAsset;
  final VoidCallback onTap;
  const _SmallAction({required this.label, this.icon, this.iconColor, this.iconAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider.withValues(alpha: 0.5))),
        child: Row(children: [
          if (icon != null) Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
          if (iconAsset != null) Image.asset(iconAsset!, width: 18, height: 18),
          const SizedBox(width: 8),
          Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}
