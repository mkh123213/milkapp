import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/milk_entry.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/repos/today_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import '../../../reports/data/repos/reports_repo.dart';
import '../../../suppliers/data/repos/suppliers_repo.dart';
import 'weight_entry_state.dart';

class WeightEntryCubit extends Cubit<WeightEntryState> {
  final TodayRepo _todayRepo;
  final AuthRepo _authRepo;
  final ReportsRepo _reportsRepo;
  final SuppliersRepo _suppliersRepo;

  WeightEntryCubit(this._todayRepo, this._authRepo, this._reportsRepo, this._suppliersRepo)
      : super(const WeightEntryInitial());

  Future<void> saveWeight({
    required String supplierId,
    required String supplierName,
    required double weight,
    String? notes,
  }) async {
    final uid = _authRepo.currentUserId;
    if (uid == null) return;
    emit(const WeightEntrySaving());
    try {
      final today = DateTime.now();
      final dateKey = MilkDateUtils.toDateKey(today);
      final existingEntry = await _todayRepo.getEntryForDate(uid, supplierId, dateKey);
      if (existingEntry != null) {
        emit(const WeightEntryError('entry_already_exists'));
        return;
      }
      final roundedWeight = double.parse(weight.toStringAsFixed(1));
      final entry = MilkEntry(
        id: '',
        supplierId: supplierId,
        supplierName: supplierName,
        date: today,
        dateKey: dateKey,
        weekKey: MilkDateUtils.getWeekKey(today),
        originalWeightKg: roundedWeight,
        currentWeightKg: roundedWeight,
        entryStatus: EntryStatus.recorded,
        createdAt: today,
        editReason: notes?.trim().isEmpty == true ? null : notes?.trim(),
      );
      await _todayRepo.addEntry(uid, entry);
      await _refreshReportIfExists(uid, entry.weekKey);
      emit(const WeightEntrySaved());
    } on FirebaseException catch (e) {
      emit(WeightEntryError(e.code == 'unavailable' ? 'auth_network_error' : 'error_generic'));
    } catch (_) {
      emit(const WeightEntryError('error_generic'));
    }
  }

  Future<void> saveNoMilk({
    required String supplierId,
    required String supplierName,
  }) async {
    final uid = _authRepo.currentUserId;
    if (uid == null) return;
    emit(const WeightEntrySaving());
    try {
      final today = DateTime.now();
      final dateKey = MilkDateUtils.toDateKey(today);
      final existingEntry = await _todayRepo.getEntryForDate(uid, supplierId, dateKey);
      if (existingEntry != null) {
        emit(const WeightEntryError('entry_already_exists'));
        return;
      }
      final entry = MilkEntry(
        id: '',
        supplierId: supplierId,
        supplierName: supplierName,
        date: today,
        dateKey: dateKey,
        weekKey: MilkDateUtils.getWeekKey(today),
        entryStatus: EntryStatus.noMilk,
        createdAt: today,
      );
      await _todayRepo.addEntry(uid, entry);
      await _refreshReportIfExists(uid, entry.weekKey);
      emit(const WeightEntrySaved());
    } on FirebaseException catch (e) {
      emit(WeightEntryError(e.code == 'unavailable' ? 'auth_network_error' : 'error_generic'));
    } catch (_) {
      emit(const WeightEntryError('error_generic'));
    }
  }

  Future<void> undoNoMilk(String supplierId) async {
    final uid = _authRepo.currentUserId;
    if (uid == null) return;
    final dateKey = MilkDateUtils.toDateKey(DateTime.now());
    final entry = await _todayRepo.getEntryForDate(uid, supplierId, dateKey);
    if (entry != null) {
      final weekKey = entry.weekKey;
      await _todayRepo.deleteEntry(uid, entry.id);
      await _refreshReportIfExists(uid, weekKey);
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
