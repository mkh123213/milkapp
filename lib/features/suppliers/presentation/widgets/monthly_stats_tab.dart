import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';
import 'stat_chip.dart';

class MonthlyStatsTab extends StatelessWidget {
  final Supplier supplier;
  final List<MilkEntry> entries;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  const MonthlyStatsTab({super.key, required this.supplier, required this.entries, required this.selectedMonth, required this.onMonthChanged});

  List<MilkEntry> get _monthEntries => entries.where((e) => e.date.year == selectedMonth.year && e.date.month == selectedMonth.month).toList();

  @override
  Widget build(BuildContext context) {
    final months = MilkDateUtils.lastNMonths(12);
    final monthData = _monthEntries;
    final recorded = monthData.where((e) => e.entryStatus == EntryStatus.recorded);
    final totalWeight = recorded.fold(0.0, (acc, e) => acc + (e.currentWeightKg ?? 0));
    final recordedDays = recorded.length;
    final noMilkDays = monthData.where((e) => e.entryStatus == EntryStatus.noMilk).length;
    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final absentDays = daysInMonth - recordedDays - noMilkDays;
    final avgWeight = recordedDays > 0 ? totalWeight / recordedDays : 0.0;
    final bestEntry = recordedDays > 0 ? recorded.reduce((a, b) => (a.currentWeightKg ?? 0) > (b.currentWeightKg ?? 0) ? a : b) : null;

    final barGroups = <BarChartGroupData>[];
    for (int day = 1; day <= daysInMonth; day++) {
      final dateKey = MilkDateUtils.toDateKey(DateTime(selectedMonth.year, selectedMonth.month, day));
      final entry = monthData.cast<MilkEntry?>().firstWhere((e) => e?.dateKey == dateKey, orElse: () => null);
      double y = 0;
      Color color = AppColors.missing.withValues(alpha: 0.3);
      if (entry != null) {
        if (entry.entryStatus == EntryStatus.noMilk) { y = 0.5; color = AppColors.noMilk.withValues(alpha: 0.5); }
        else { y = entry.currentWeightKg ?? 0; color = AppColors.primary; }
      }
      barGroups.add(BarChartGroupData(x: day, barRods: [BarChartRodData(toY: y, color: color, width: 8, borderRadius: BorderRadius.circular(2))]));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, itemCount: months.length,
              itemBuilder: (_, i) {
                final m = months[i];
                final selected = m.year == selectedMonth.year && m.month == selectedMonth.month;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => onMonthChanged(m),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: selected ? AppColors.primary : AppColors.divider.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)), child: Text(MilkDateUtils.formatMonthYear(m), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.textSecondary))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            StatChipWidget(label: 'total'.tr(), value: '${MilkDateUtils.toArabicNumeralsStr(totalWeight.toStringAsFixed(1))} ${'unit_kg'.tr()}'),
            const SizedBox(width: 8),
            StatChipWidget(label: 'average'.tr(), value: '${MilkDateUtils.toArabicNumeralsStr(avgWeight.toStringAsFixed(1))} ${'unit_kg'.tr()}'),
            if (bestEntry != null) ...[const SizedBox(width: 8), StatChipWidget(label: 'best_day'.tr(), value: '${MilkDateUtils.toArabicNumeralsStr((bestEntry.currentWeightKg ?? 0).toStringAsFixed(1))} ${'unit_kg'.tr()}')],
          ]),
          const SizedBox(height: 8),
          Text('${'attendance_days'.tr()}: ${MilkDateUtils.toArabicNumerals(recordedDays)} | ${'absence_days'.tr()}: ${MilkDateUtils.toArabicNumerals(absentDays < 0 ? 0 : absentDays)} | ${'zero_days'.tr()}: ${MilkDateUtils.toArabicNumerals(noMilkDays)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          if (barGroups.isNotEmpty)
            Container(
              height: 160, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: BarChart(BarChartData(barGroups: barGroups, titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(MilkDateUtils.toArabicNumerals(v.toInt()), style: const TextStyle(fontSize: 8)), interval: 5, reservedSize: 18)), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))), gridData: const FlGridData(show: false), borderData: FlBorderData(show: false))),
            )
          else if (monthData.isEmpty)
            Center(child: Text('no_records_month'.tr(), style: const TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
