import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/supplier.dart';
import '../../data/repos/suppliers_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import 'route_ordering_state.dart';

class RouteOrderingCubit extends Cubit<RouteOrderingState> {
  final SuppliersRepo _suppliersRepo;
  final AuthRepo _authRepo;
  List<Supplier> _original = [];

  RouteOrderingCubit(this._suppliersRepo, this._authRepo)
      : super(const RouteOrderingState());

  void init(List<Supplier> suppliers) {
    _original = List.from(suppliers);
    emit(state.copyWith(ordered: List.from(suppliers)));
  }

  void reorder(int oldIndex, int newIndex) {
    final list = List<Supplier>.from(state.ordered);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    emit(state.copyWith(ordered: list, changeCount: _countChanges(list)));
  }

  void autoSort() {
    final list = List<Supplier>.from(state.ordered);
    list.sort((a, b) {
      final v = (a.village ?? '').compareTo(b.village ?? '');
      return v != 0 ? v : a.name.compareTo(b.name);
    });
    emit(state.copyWith(ordered: list, changeCount: _countChanges(list)));
  }

  Future<void> save() async {
    final uid = _authRepo.currentUserId;
    if (uid == null) return;
    emit(state.copyWith(saving: true));
    final updates = <String, int>{};
    for (int i = 0; i < state.ordered.length; i++) {
      updates[state.ordered[i].id] = i + 1;
    }
    await _suppliersRepo.bulkUpdateRouteOrder(uid, updates);
    emit(state.copyWith(saving: false, saved: true));
  }

  int _countChanges(List<Supplier> list) {
    int changes = 0;
    for (int i = 0; i < list.length; i++) {
      if (i >= _original.length || list[i].id != _original[i].id) changes++;
    }
    return changes;
  }
}
