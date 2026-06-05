import '../../../../shared/models/supplier.dart';

abstract class AddEditSupplierState {
  const AddEditSupplierState();
}

class AddEditSupplierInitial extends AddEditSupplierState {
  const AddEditSupplierInitial();
}

class AddEditSupplierLoaded extends AddEditSupplierState {
  final Supplier supplier;
  const AddEditSupplierLoaded(this.supplier);
}

class AddEditSupplierSaving extends AddEditSupplierState {
  const AddEditSupplierSaving();
}

class AddEditSupplierSaved extends AddEditSupplierState {
  final String? newId;
  final String name;
  const AddEditSupplierSaved({this.newId, required this.name});
}

class AddEditSupplierError extends AddEditSupplierState {
  final String errorKey;
  const AddEditSupplierError(this.errorKey);
}
