import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/supplier.dart';
import '../../data/repos/suppliers_repo.dart';
import '../../../auth/data/repos/auth_repo.dart';
import 'add_edit_supplier_state.dart';

class AddEditSupplierCubit extends Cubit<AddEditSupplierState> {
  final SuppliersRepo _suppliersRepo;
  final AuthRepo _authRepo;

  AddEditSupplierCubit(this._suppliersRepo, this._authRepo)
      : super(const AddEditSupplierInitial());

  String? get _uid => _authRepo.currentUserId;

  void loadSupplier(List<Supplier> suppliers, String id) {
    final s = suppliers.cast<Supplier?>().firstWhere(
        (s) => s?.id == id,
        orElse: () => null);
    if (s != null) emit(AddEditSupplierLoaded(s));
  }

  Future<void> save({
    required String? supplierId,
    required String name,
    required String phone,
    required String village,
    required String address,
    required String orderStr,
    required String notes,
    required bool isActive,
    Supplier? original,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    emit(const AddEditSupplierSaving());

    int order = int.tryParse(orderStr.trim()) ?? 0;
    if (order <= 0) order = await _suppliersRepo.getMaxRouteOrder(uid) + 1;

    if (supplierId != null && original != null) {
      final wasActive = original.isActive;
      await _suppliersRepo.updateSupplier(uid, supplierId, {
        'name': name.trim(),
        'phone': phone.trim().isEmpty ? null : phone.trim(),
        'village': village.trim().isEmpty ? null : village.trim(),
        'address': address.trim().isEmpty ? null : address.trim(),
        'routeOrder': order,
        'isActive': isActive,
        'notes': notes.trim().isEmpty ? null : notes.trim(),
        if (!isActive && wasActive)
          'deactivatedAt': Timestamp.fromDate(DateTime.now()),
        if (isActive && !wasActive) 'deactivatedAt': null,
      });
      emit(AddEditSupplierSaved(name: name.trim()));
    } else {
      final supplier = Supplier(
        id: '',
        name: name.trim(),
        phone: phone.trim().isEmpty ? null : phone.trim(),
        village: village.trim().isEmpty ? null : village.trim(),
        address: address.trim().isEmpty ? null : address.trim(),
        routeOrder: order,
        isActive: true,
        notes: notes.trim().isEmpty ? null : notes.trim(),
        addedAt: DateTime.now(),
      );
      final id = await _suppliersRepo.addSupplier(uid, supplier);
      emit(AddEditSupplierSaved(newId: id, name: name.trim()));
    }
  }
}
