import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';
import '../../../../shared/models/weekly_report.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/repos/today_repo.dart';
import '../../../suppliers/data/repos/suppliers_repo.dart';
import '../../../reports/data/repos/reports_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import 'today_state.dart';

class TodayCubit extends Cubit<TodayState> {
  final TodayRepo _todayRepo;
  final SuppliersRepo _suppliersRepo;
  final ReportsRepo _reportsRepo;
  final AuthRepo _authRepo;
  StreamSubscription? _suppliersSub;
  StreamSubscription? _entriesSub;
  StreamSubscription? _reportsSub;
  Timer? _searchDebounce;

  TodayCubit(this._todayRepo, this._suppliersRepo, this._reportsRepo, this._authRepo)
      : super(const TodayState());

  String? get _uid => _authRepo.currentUserId;

  void load() {
    final uid = _uid;
    if (uid == null) return;

    _suppliersSub = _suppliersRepo.watchActiveSuppliers(uid).listen((suppliers) {
      final sorted = List<Supplier>.from(suppliers)
        ..sort((a, b) {
          final cmp = a.routeOrder.compareTo(b.routeOrder);
          return cmp != 0 ? cmp : a.name.compareTo(b.name);
        });
      emit(state.copyWith(suppliers: sorted, loading: false));
      _rebuildLists();
    });

    final dateKey = MilkDateUtils.toDateKey(DateTime.now());
    _entriesSub = _todayRepo.watchEntriesForDate(uid, dateKey).listen((entries) {
      final map = {for (final e in entries) e.supplierId: e};
      emit(state.copyWith(entriesMap: map));
      _rebuildLists();
    });

    final weekKey = MilkDateUtils.getWeekKey(DateTime.now());
    _reportsSub = _reportsRepo.watchReports(uid).listen((reports) {
      final current = reports.cast<WeeklyReport?>().firstWhere(
          (r) => r?.weekKey == weekKey,
          orElse: () => null);
      emit(state.copyWith(isWeekLocked: current?.isFinalized ?? false));
    });
  }

  void setSearch(String query) {
    emit(state.copyWith(search: query));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _rebuildLists);
  }

  void setVillageFilter(String? village) {
    if (village == null) {
      emit(state.copyWith(clearVillageFilter: true));
    } else {
      emit(state.copyWith(villageFilter: village));
    }
    _rebuildLists();
  }

  void _rebuildLists() {
    final suppliers = state.suppliers;
    final entriesMap = state.entriesMap;

    var pending = suppliers.where((s) => !entriesMap.containsKey(s.id)).toList();
    var received = suppliers.where((s) => entriesMap[s.id]?.entryStatus == EntryStatus.recorded).toList();
    var noMilk = suppliers.where((s) => entriesMap[s.id]?.entryStatus == EntryStatus.noMilk).toList();

    pending = _applyFilters(pending);
    received = _applyFilters(received);
    noMilk = _applyFilters(noMilk);

    final totalToday = entriesMap.values
        .where((e) => e.entryStatus == EntryStatus.recorded)
        .fold(0.0, (acc, e) => acc + (e.currentWeightKg ?? 0));

    emit(state.copyWith(pendingList: pending, receivedList: received, noMilkList: noMilk, totalToday: totalToday));
  }

  List<Supplier> _applyFilters(List<Supplier> list) {
    var result = list;
    if (state.search.isNotEmpty) {
      final q = state.search.toLowerCase();
      result = result.where((s) => s.name.toLowerCase().contains(q) || (s.village?.toLowerCase().contains(q) ?? false) || (s.phone?.contains(q) ?? false)).toList();
    }
    if (state.villageFilter != null) {
      result = result.where((s) => s.village == state.villageFilter).toList();
    }
    return result;
  }

  @override
  Future<void> close() {
    _suppliersSub?.cancel();
    _entriesSub?.cancel();
    _reportsSub?.cancel();
    _searchDebounce?.cancel();
    return super.close();
  }
}
