import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/constants.dart';
import '../../data/models/dashboard_stats.dart';
import '../../../suppliers/data/repos/suppliers_repo.dart';
import '../../../today/data/repos/today_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final SuppliersRepo _suppliersRepo;
  final TodayRepo _todayRepo;
  final AuthRepo _authRepo;
  StreamSubscription? _suppliersSub;
  StreamSubscription? _entriesSub;
  StreamSubscription? _weekSub;
  double _weekWeight = 0;
  List<MilkEntry> _weekEntries = [];

  DashboardCubit(this._suppliersRepo, this._todayRepo, this._authRepo)
      : super(DashboardState());

  String? get _uid => _authRepo.currentUserId;

  void load() {
    final uid = _uid;
    if (uid == null) return;

    _suppliersSub = _suppliersRepo.watchActiveSuppliers(uid).listen((suppliers) {
      final sorted = List<Supplier>.from(suppliers)..sort((a, b) { final c = a.routeOrder.compareTo(b.routeOrder); return c != 0 ? c : a.name.compareTo(b.name); });
      emit(state.copyWith(suppliers: sorted, loading: false));
      _recompute();
    });

    final dateKey = MilkDateUtils.toDateKey(DateTime.now());
    _entriesSub = _todayRepo.watchEntriesForDate(uid, dateKey).listen((entries) {
      emit(state.copyWith(entriesMap: {for (final e in entries) e.supplierId: e}));
      _recompute();
    });

    final weekKey = MilkDateUtils.getWeekKey(DateTime.now());
    _weekSub = _todayRepo.watchEntriesForWeek(uid, weekKey).listen((entries) {
      _weekEntries = entries;
      _weekWeight = entries.where((e) => e.entryStatus == EntryStatus.recorded).fold(0.0, (acc, e) => acc + (e.currentWeightKg ?? 0));
      _recompute();
    });
  }

  void refresh() {
    final uid = _uid;
    if (uid == null) return;
    // Streams auto-update; just trigger a recompute
    _recompute();
  }

  void _recompute() {
    final suppliers = state.suppliers;
    final entriesMap = state.entriesMap;

    final received = suppliers.where((s) => entriesMap[s.id]?.entryStatus == EntryStatus.recorded).length;
    final noMilk = suppliers.where((s) => entriesMap[s.id]?.entryStatus == EntryStatus.noMilk).length;
    final pending = suppliers.where((s) => !entriesMap.containsKey(s.id)).length;
    final edited = entriesMap.values.where((e) => e.isEdited).length;
    final todayWeight = entriesMap.values.where((e) => e.entryStatus == EntryStatus.recorded).fold(0.0, (acc, e) => acc + (e.currentWeightKg ?? 0));

    final today = DateTime.now();
    final absent = suppliers.where((s) {
      final supplierEntryKeys = _weekEntries
          .where((e) => e.supplierId == s.id)
          .map((e) => e.dateKey)
          .toSet();
      final streak = MilkDateUtils.calcAbsenceStreak(today, supplierEntryKeys, s.addedAt);
      return streak >= AppConstants.absenceAlertDays;
    }).toList();

    emit(state.copyWith(
      stats: DashboardStats(totalSuppliers: suppliers.length, receivedToday: received, pendingToday: pending, noMilkToday: noMilk, editedToday: edited, todayWeight: todayWeight, weekWeight: _weekWeight),
      absentSuppliers: absent,
    ));
  }

  @override
  Future<void> close() {
    _suppliersSub?.cancel();
    _entriesSub?.cancel();
    _weekSub?.cancel();
    return super.close();
  }
}
