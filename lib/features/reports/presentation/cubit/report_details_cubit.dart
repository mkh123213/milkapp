import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/weekly_report.dart';
import '../../../../shared/models/milk_entry.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/repos/reports_repo.dart';
import '../../../today/data/repos/today_repo.dart';
import '../../../suppliers/data/repos/suppliers_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import 'report_details_state.dart';

class ReportDetailsCubit extends Cubit<ReportDetailsState> {
  final ReportsRepo _reportsRepo;
  final TodayRepo _todayRepo;
  final SuppliersRepo _suppliersRepo;
  final AuthRepo _authRepo;

  ReportDetailsCubit(this._reportsRepo, this._todayRepo, this._suppliersRepo, this._authRepo)
      : super(const ReportDetailsState());

  String? get _uid => _authRepo.currentUserId;

  Future<void> load(String reportId) async {
    final uid = _uid;
    if (uid == null) return;
    emit(state.copyWith(loading: true));

    final db = FirebaseFirestore.instance;
    final doc = await db.collection('users').doc(uid).collection('weekly_reports').doc(reportId).get();
    if (!doc.exists) { emit(state.copyWith(loading: false)); return; }

    final report = WeeklyReport.fromFirestore(doc);
    final entries = await _todayRepo.watchEntriesForWeek(uid, report.weekKey).first;
    final suppliers = await _suppliersRepo.getActiveSuppliers(uid);

    final totalWeight = entries
        .where((e) => e.entryStatus == EntryStatus.recorded)
        .fold(0.0, (acc, e) => acc + (e.currentWeightKg ?? 0));
    final noMilkCount = entries
        .where((e) => e.entryStatus == EntryStatus.noMilk)
        .length;
    final editedCount = entries.where((e) => e.isEdited).length;
    final recordedDays = entries
        .map((e) => '${e.supplierId}_${e.dateKey}')
        .toSet()
        .length;
    final expectedDays = suppliers.length * 7;
    final missingCount = expectedDays - recordedDays;

    final updatedReport = report.copyWith(
      totalWeightKg: totalWeight,
      noMilkEntriesCount: noMilkCount,
      editedEntriesCount: editedCount,
      missingEntriesCount: missingCount < 0 ? 0 : missingCount,
      supplierCount: suppliers.length,
    );

    emit(state.copyWith(report: updatedReport, entries: entries, suppliers: suppliers, loading: false));

    _reportsRepo.refreshReportStats(uid, reportId, report.weekKey, suppliers.length);
  }

  Future<bool> finalize(String reportId) async {
    final uid = _uid;
    if (uid == null) return false;
    emit(state.copyWith(finalizing: true));
    final userEmail = _authRepo.currentUserEmail;
    await _reportsRepo.updateReport(uid, reportId, {
      'status': 'finalized',
      'finalizedAt': Timestamp.fromDate(DateTime.now()),
      'finalizedBy': userEmail,
    });
    await load(reportId);
    emit(state.copyWith(finalizing: false));
    return true;
  }

  String generateShareText() {
    if (state.report == null) return '';
    final r = state.report!;
    final total = MilkDateUtils.toArabicNumeralsStr(r.totalWeightKg.toStringAsFixed(1));
    return 'تقرير الحليب الأسبوعي\n'
        'الفترة: ${MilkDateUtils.formatShortHeader(r.weekStartDate)} — ${MilkDateUtils.formatShortHeader(r.weekEndDate)}\n'
        'إجمالي الوزن: $total كغ\n'
        'عدد المربيين: ${MilkDateUtils.toArabicNumerals(r.supplierCount)}\n'
        'أيام مفقودة: ${MilkDateUtils.toArabicNumerals(r.missingEntriesCount)}\n'
        'الحالة: ${r.isFinalized ? 'نهائي' : 'مسودة'}\n'
        '─────────────────\n'
        'أُعدّ بواسطة: دفتر الحليب';
  }
}
