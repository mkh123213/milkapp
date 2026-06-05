import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/weekly_report.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/repos/reports_repo.dart';
import '../../../suppliers/data/repos/suppliers_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import 'reports_list_state.dart';

class ReportsListCubit extends Cubit<ReportsListState> {
  final ReportsRepo _reportsRepo;
  final SuppliersRepo _suppliersRepo;
  final AuthRepo _authRepo;
  StreamSubscription? _sub;
  bool _isCreating = false;

  ReportsListCubit(this._reportsRepo, this._suppliersRepo, this._authRepo)
      : super(const ReportsListLoading());

  String? get _uid => _authRepo.currentUserId;

  void load() {
    final uid = _uid;
    if (uid == null) return;
    _sub = _reportsRepo.watchReports(uid).listen(
      (reports) => emit(ReportsListLoaded(reports)),
    );
  }

  Future<String?> createReport() async {
    if (_isCreating) return null;
    final uid = _uid;
    if (uid == null) return null;
    _isCreating = true;
    try {
    final weekKey = MilkDateUtils.getWeekKey(DateTime.now());
    final existing = await _reportsRepo.getReportForWeek(uid, weekKey);
    if (existing != null) { _isCreating = false; return existing.id; }

    final current = state;
    if (current is ReportsListLoaded) emit(ReportsListCreating(current.reports));

    final now = DateTime.now();
    final weekStart = MilkDateUtils.getWeekStart(now);
    final weekEnd = MilkDateUtils.getWeekEnd(weekStart);
    final activeSuppliers = await _suppliersRepo.getActiveSuppliers(uid);
    final report = WeeklyReport(
      id: '', weekKey: weekKey, weekStartDate: weekStart, weekEndDate: weekEnd,
      totalWeightKg: 0, missingEntriesCount: 0, noMilkEntriesCount: 0,
      editedEntriesCount: 0, supplierCount: activeSuppliers.length,
      status: ReportStatus.draft, createdAt: now,
    );
    final id = await _reportsRepo.createReport(uid, report);
    await _reportsRepo.refreshReportStats(uid, id, weekKey, activeSuppliers.length);
    return id;
    } finally {
      _isCreating = false;
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
