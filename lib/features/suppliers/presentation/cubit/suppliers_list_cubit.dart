import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/milk_entry.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../today/data/repos/today_repo.dart';
import '../../data/repos/suppliers_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import 'suppliers_list_state.dart';

class SuppliersListCubit extends Cubit<SuppliersListState> {
  final SuppliersRepo _suppliersRepo;
  final TodayRepo _todayRepo;
  final AuthRepo _authRepo;
  StreamSubscription? _suppliersSub;
  StreamSubscription? _weekSub;
  Timer? _searchDebounce;

  SuppliersListCubit(this._suppliersRepo, this._todayRepo, this._authRepo)
      : super(const SuppliersListState());

  String? get _uid => _authRepo.currentUserId;

  void load() {
    final uid = _uid;
    if (uid == null) return;

    _suppliersSub = _suppliersRepo.watchSuppliers(uid).listen((suppliers) {
      emit(state.copyWith(allSuppliers: suppliers, loading: false));
      _applyFilter();
    });

    final weekKey = MilkDateUtils.getWeekKey(DateTime.now());
    _weekSub = _todayRepo.watchEntriesForWeek(uid, weekKey).listen((entries) {
      emit(state.copyWith(weeklyEntries: entries));
    });
  }

  void setSearch(String query) {
    emit(state.copyWith(search: query));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _applyFilter);
  }

  void setFilterMode(String mode) {
    emit(state.copyWith(filterMode: mode));
    _applyFilter();
  }

  double weekTotalForSupplier(String supplierId) {
    return state.weeklyEntries
        .where((e) =>
            e.supplierId == supplierId &&
            e.entryStatus == EntryStatus.recorded)
        .fold(0.0, (acc, e) => acc + (e.currentWeightKg ?? 0));
  }

  void _applyFilter() {
    var result = state.allSuppliers;
    if (state.filterMode == 'active') {
      result = result.where((s) => s.isActive).toList();
    } else if (state.filterMode == 'inactive') {
      result = result.where((s) => !s.isActive).toList();
    }
    if (state.search.isNotEmpty) {
      final q = state.search.toLowerCase();
      result = result
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              (s.village?.toLowerCase().contains(q) ?? false) ||
              (s.phone?.contains(q) ?? false))
          .toList();
    }
    emit(state.copyWith(filteredSuppliers: result));
  }

  @override
  Future<void> close() {
    _suppliersSub?.cancel();
    _weekSub?.cancel();
    _searchDebounce?.cancel();
    return super.close();
  }
}
