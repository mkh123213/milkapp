import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/weekly_report.dart';
import '../../../../shared/models/milk_entry.dart';
import '../../../../shared/models/supplier.dart';

class WeeklyTable extends StatelessWidget {
  final WeeklyReport report;
  final List<MilkEntry> entries;
  final List<Supplier> suppliers;
  const WeeklyTable({super.key, required this.report, required this.entries, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final weekDays = MilkDateUtils.getWeekDays(report.weekStartDate);
    final entryMap = {for (final e in entries) '${e.supplierId}_${e.dateKey}': e};

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(60),
        columnWidths: const {0: FixedColumnWidth(120)},
        border: TableBorder.all(color: AppColors.divider, width: 0.5),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: AppColors.primary),
            children: [
              _Cell('supplier_col'.tr(), isHeader: true),
              ...weekDays.map((d) => _Cell(MilkDateUtils.formatShortHeader(d), isHeader: true)),
              _Cell('total_col'.tr(), isHeader: true),
            ],
          ),
          ...suppliers.map((s) {
            double total = 0;
            return TableRow(children: [
              _NameCell(s.name),
              ...weekDays.map((d) {
                final key = '${s.id}_${MilkDateUtils.toDateKey(d)}';
                final entry = entryMap[key];
                if (entry == null) {
                  if (d.isBefore(s.addedAt)) return _DataCell('—', AppColors.divider, null);
                  return _DataCell('--', AppColors.missing.withValues(alpha: 0.15), null);
                }
                if (entry.entryStatus == EntryStatus.noMilk) return _DataCell('0', AppColors.noMilkBg, null);
                total += entry.currentWeightKg ?? 0;
                final label = entry.isEdited ? '${(entry.currentWeightKg ?? 0).toStringAsFixed(1)}*' : (entry.currentWeightKg ?? 0).toStringAsFixed(1);
                return _DataCell(label, entry.isEdited ? AppColors.editedBg : null, entry.isEdited ? AppColors.edited : null);
              }),
              _DataCell(total.toStringAsFixed(1), AppColors.primary.withValues(alpha: 0.08), AppColors.primary),
            ]);
          }),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool isHeader;
  const _Cell(this.text, {this.isHeader = false});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6), child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: isHeader ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 11)));
}

class _NameCell extends StatelessWidget {
  final String name;
  const _NameCell(this.name);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8), child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis));
}

class _DataCell extends StatelessWidget {
  final String text; final Color? bg; final Color? fg;
  const _DataCell(this.text, this.bg, this.fg);
  @override
  Widget build(BuildContext context) => Container(color: bg, padding: const EdgeInsets.symmetric(vertical: 6), child: Text(MilkDateUtils.toArabicNumeralsStr(text), textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg ?? AppColors.textPrimary)));
}
