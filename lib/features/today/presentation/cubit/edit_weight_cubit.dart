import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/today_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import '../../../reports/data/repos/reports_repo.dart';
import '../../../suppliers/data/repos/suppliers_repo.dart';
import 'edit_weight_state.dart';

class EditWeightCubit extends Cubit<EditWeightState> {
  final TodayRepo _todayRepo;
  final AuthRepo _authRepo;
  final ReportsRepo _reportsRepo;
  final SuppliersRepo _suppliersRepo;

  EditWeightCubit(this._todayRepo, this._authRepo, this._reportsRepo, this._suppliersRepo)
      : super(const EditWeightLoading());

  Future<void> loadEntry(String entryId) async {
    final uid = _authRepo.currentUserId;
    if (uid == null) return;
    final entry = await _todayRepo.getEntryById(uid, entryId);
    if (entry != null) {
      emit(EditWeightLoaded(entry));
    } else {
      emit(const EditWeightError('entry_not_found'));
    }
  }

  Future<void> save(String entryId, double newWeight, String reason) async {
    final uid = _authRepo.currentUserId;
    if (uid == null) return;
    final current = state;
    if (current is! EditWeightLoaded) return;
    emit(EditWeightSaving(current.entry));
    try {
      final roundedWeight = double.parse(newWeight.toStringAsFixed(1));
      await _todayRepo.updateEntry(uid, entryId, {
        'currentWeightKg': roundedWeight,
        'editCount': 1,
        'editReason': reason,
        'editedAt': Timestamp.fromDate(DateTime.now()),
        'editedBy': _authRepo.currentUserEmail,
      });
      await _refreshReportIfExists(uid, current.entry.weekKey);
      emit(const EditWeightSaved());
    } on FirebaseException catch (e) {
      emit(EditWeightError(e.code == 'unavailable' ? 'auth_network_error' : 'error_generic'));
    } catch (_) {
      emit(const EditWeightError('error_generic'));
    }
  }

  Future<void> _refreshReportIfExists(String uid, String weekKey) async {
    try {
      final report = await _reportsRepo.getReportForWeek(uid, weekKey);
      if (report == null) return;
      final suppliers = await _suppliersRepo.getActiveSuppliers(uid);
      await _reportsRepo.refreshReportStats(uid, report.id, weekKey, suppliers.length);
    } catch (_) {}
  }
}
