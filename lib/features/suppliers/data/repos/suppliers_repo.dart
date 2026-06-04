import '../../../../shared/models/supplier.dart';
import '../data_source/suppliers_remote_data_source.dart';

class SuppliersRepo {
  final SuppliersRemoteDataSource _ds;

  SuppliersRepo(this._ds);

  Stream<List<Supplier>> watchSuppliers(String uid) =>
      _ds.watchSuppliers(uid);

  Stream<List<Supplier>> watchActiveSuppliers(String uid) =>
      _ds.watchActiveSuppliers(uid);

  Future<List<Supplier>> getActiveSuppliers(String uid) =>
      _ds.getActiveSuppliers(uid);

  Future<String> addSupplier(String uid, Supplier supplier) =>
      _ds.addSupplier(uid, supplier);

  Future<void> updateSupplier(
          String uid, String id, Map<String, dynamic> data) =>
      _ds.updateSupplier(uid, id, data);

  Future<void> deleteSupplier(String uid, String id) =>
      _ds.deleteSupplier(uid, id);

  Future<int> getMaxRouteOrder(String uid) => _ds.getMaxRouteOrder(uid);

  Future<void> bulkUpdateRouteOrder(
          String uid, Map<String, int> updates) =>
      _ds.bulkUpdateRouteOrder(uid, updates);
}
