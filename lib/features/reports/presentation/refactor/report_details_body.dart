import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/asset_paths.dart';
import '../../../../core/constants.dart';
import '../cubit/report_details_cubit.dart';
import '../cubit/report_details_state.dart';
import '../widgets/weekly_table.dart';

class ReportDetailsBody extends StatelessWidget {
  final String reportId;
  const ReportDetailsBody({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportDetailsCubit, ReportDetailsState>(
      builder: (context, state) {
        if (state.loading) return Scaffold(backgroundColor: AppColors.background, body: Column(children: [_buildHeader(context, null, false), const Expanded(child: Center(child: CircularProgressIndicator()))]));
        final report = state.report;
        if (report == null) return Scaffold(backgroundColor: AppColors.background, body: Column(children: [_buildHeader(context, null, false), Expanded(child: Center(child: Text('report_not_found'.tr())))]));

        final isFinalized = report.isFinalized;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _buildHeader(context, isFinalized ? 'report_final'.tr() : 'report_draft'.tr(), isFinalized),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<ReportDetailsCubit>().load(reportId),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                        _StatBox(label: 'total_weight'.tr(), value: '${MilkDateUtils.toArabicNumeralsStr(report.totalWeightKg.toStringAsFixed(1))} ${'unit_kg'.tr()}', color: AppColors.primary),
                        const SizedBox(width: 8),
                        _StatBox(label: 'missing_records'.tr(), value: MilkDateUtils.toArabicNumerals(report.missingEntriesCount), color: AppColors.alert),
                        const SizedBox(width: 8),
                        _StatBox(label: 'stat_no_milk'.tr(), value: MilkDateUtils.toArabicNumerals(report.noMilkEntriesCount), color: AppColors.noMilk),
                        const SizedBox(width: 8),
                        _StatBox(label: 'edited_records'.tr(), value: MilkDateUtils.toArabicNumerals(report.editedEntriesCount), color: AppColors.edited),
                      ])),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text('weight_table'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      WeeklyTable(report: report, entries: state.entries, suppliers: state.suppliers),
                      Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                        _Legend('--', AppColors.missing, 'missing_legend'.tr()),
                        const SizedBox(width: 12),
                        _Legend('0', AppColors.noMilk, 'no_milk_legend'.tr()),
                        const SizedBox(width: 12),
                        _Legend('*', AppColors.edited, 'edited_legend'.tr()),
                      ])),
                      Padding(padding: const EdgeInsets.all(12), child: Column(children: [
                        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => Share.share(context.read<ReportDetailsCubit>().generateShareText()), icon: const Icon(Icons.share, color: Colors.white), label: Text('share_whatsapp'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.whatsApp, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                        if (!isFinalized) ...[
                          const SizedBox(height: 10),
                          SizedBox(width: double.infinity, child: ElevatedButton.icon(
                            onPressed: state.finalizing ? null : () async {
                              final confirmed = await _confirmFinalize(context);
                              if (confirmed && context.mounted) {
                                await context.read<ReportDetailsCubit>().finalize(reportId);
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('report_closed'.tr()), backgroundColor: AppColors.primary));
                              }
                            },
                            icon: state.finalizing ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock, color: Colors.white),
                            label: Text('close_week'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          )),
                        ],
                      ])),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String? title, bool isFinalized) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(bottom: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20, color: Colors.white))),
        const SizedBox(width: 12),
        Expanded(child: Text(title ?? 'report_details_title'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
        if (isFinalized) Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.lock, size: 16, color: Colors.white)),
      ]))),
    );
  }

  Future<bool> _confirmFinalize(BuildContext context) async {
    final result = await showDialog<bool>(context: context, builder: (_) => _FinalizeDialog());
    return result ?? false;
  }
}

class _StatBox extends StatelessWidget {
  final String label; final String value; final Color color;
  const _StatBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)), Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10))])));
}

class _Legend extends StatelessWidget {
  final String symbol; final Color color; final String desc;
  const _Legend(this.symbol, this.color, this.desc);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 20, height: 20, alignment: Alignment.center, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)), child: Text(symbol, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11))), const SizedBox(width: 4), Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))]);
}

class _FinalizeDialog extends StatefulWidget {
  @override
  State<_FinalizeDialog> createState() => _FinalizeDialogState();
}

class _FinalizeDialogState extends State<_FinalizeDialog> {
  int _countdown = AppConstants.finalizationCountdownSeconds;
  late final _timer = Stream.periodic(const Duration(seconds: 1), (i) => i).take(AppConstants.finalizationCountdownSeconds).listen((_) { if (mounted) setState(() => _countdown--); });

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('finalize_title'.tr()),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.danger.withValues(alpha: 0.3))), child: Row(children: [Image.asset(AssetPaths.iconWarning, width: 16, height: 16), const SizedBox(width: 6), Expanded(child: Text('finalize_warning'.tr(), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13)))])),
        const SizedBox(height: 12),
        Text('finalize_no_edit_warning'.tr(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('cancel'.tr())),
        ElevatedButton(
          onPressed: _countdown > 0 ? null : () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(_countdown > 0 ? 'wait_countdown'.tr(args: [MilkDateUtils.toArabicNumerals(_countdown)]) : 'confirm_close_week'.tr(), style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
