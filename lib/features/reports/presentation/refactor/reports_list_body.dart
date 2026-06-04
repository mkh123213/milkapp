import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/weekly_report.dart';
import '../cubit/reports_list_cubit.dart';
import '../cubit/reports_list_state.dart';

class ReportsListBody extends StatelessWidget {
  const ReportsListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('reports_title'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final id = await context.read<ReportsListCubit>().createReport();
                        if (id != null && context.mounted) context.push('/reports/$id');
                      },
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: Text('create_report'.tr(), style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ReportsListCubit, ReportsListState>(
              builder: (context, state) {
                if (state is ReportsListLoading) return const Center(child: CircularProgressIndicator());
                final reports = state is ReportsListLoaded ? state.reports : (state is ReportsListCreating ? state.reports : <WeeklyReport>[]);
                if (reports.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Image.asset(AssetPaths.iconChart, width: 48, height: 48, opacity: const AlwaysStoppedAnimation(0.3)),
                    const SizedBox(height: 12),
                    Text('no_reports_yet'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('no_reports_hint'.tr(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ]));
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<ReportsListCubit>().load(),
                  child: ListView.builder(
                    itemCount: reports.length,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                    itemBuilder: (_, i) => _ReportCard(report: reports[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final WeeklyReport report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final isFinalized = report.isFinalized;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/reports/${report.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${MilkDateUtils.formatShortHeader(report.weekStartDate)} - ${MilkDateUtils.formatShortHeader(report.weekEndDate)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text('${MilkDateUtils.toDateKey(report.weekStartDate)} — ${MilkDateUtils.toDateKey(report.weekEndDate)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (isFinalized) const Icon(Icons.lock, size: 12, color: AppColors.primary) else Image.asset(AssetPaths.iconDocument, width: 12, height: 12),
                  const SizedBox(width: 4),
                  Text(isFinalized ? 'status_final'.tr() : 'status_draft'.tr(), style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _Stat(value: '${MilkDateUtils.toArabicNumeralsStr(report.totalWeightKg.toStringAsFixed(1))} ${'unit_kg'.tr()}', label: 'total_weight'.tr(), color: AppColors.primary),
              Container(width: 1, height: 32, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 12)),
              _Stat(value: MilkDateUtils.toArabicNumerals(report.missingEntriesCount), label: 'missing_records'.tr(), color: AppColors.textSecondary),
              Container(width: 1, height: 32, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 12)),
              _Stat(value: MilkDateUtils.toArabicNumerals(report.editedEntriesCount), label: 'edited_records'.tr(), color: AppColors.edited),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Stat({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
  ]);
}
