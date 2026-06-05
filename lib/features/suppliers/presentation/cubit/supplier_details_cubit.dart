import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../today/data/repos/today_repo.dart';
import '../../data/repos/suppliers_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import 'supplier_details_state.dart';

class SupplierDetailsCubit extends Cubit<SupplierDetailsState> {
  final SuppliersRepo _suppliersRepo;
  final TodayRepo _todayRepo;
  final AuthRepo _authRepo;
  StreamSubscription? _supplierSub;
  StreamSubscription? _todayEntrySub;

  SupplierDetailsCubit(this._suppliersRepo, this._todayRepo, this._authRepo)
      : super(SupplierDetailsState());

  String? get _uid => _authRepo.currentUserId;

  void load(String supplierId) {
    final uid = _uid;
    if (uid == null) return;

    _supplierSub =
        _suppliersRepo.watchSuppliers(uid).listen((suppliers) {
      final supplier = suppliers.cast<Supplier?>().firstWhere(
          (s) => s?.id == supplierId,
          orElse: () => null);
      emit(state.copyWith(supplier: supplier));
    });

    final dateKey = MilkDateUtils.toDateKey(DateTime.now());
    _todayEntrySub =
        _todayRepo.watchEntriesForDate(uid, dateKey).listen((entries) {
      final entry = entries.cast<MilkEntry?>().firstWhere(
          (e) => e?.supplierId == supplierId,
          orElse: () => null);
      emit(state.copyWith(todayEntry: entry));
    });

    _loadEntries(supplierId);
  }

  Future<void> _loadEntries(String supplierId) async {
    final uid = _uid;
    if (uid == null) return;
    final m = state.selectedMonth;
    final from = DateTime(m.year, m.month - 3, 1);
    final to = DateTime(m.year, m.month + 1, 0);
    final entries =
        await _todayRepo.getEntriesForSupplier(uid, supplierId, from, to);
    emit(state.copyWith(entries: entries, loading: false));
  }

  void changeMonth(String supplierId, DateTime month) {
    emit(state.copyWith(selectedMonth: month, loading: true));
    _loadEntries(supplierId);
  }

  @override
  Future<void> close() {
    _supplierSub?.cancel();
    _todayEntrySub?.cancel();
    return super.close();
  }
}
