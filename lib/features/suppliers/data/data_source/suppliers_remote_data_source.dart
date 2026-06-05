import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/supplier.dart';

class SuppliersRemoteDataSource {
  final FirebaseFirestore _db;

  SuppliersRemoteDataSource(this._db);

  CollectionReference _col(String uid) =>
      _db.collection('users').doc(uid).collection('suppliers');

  Stream<List<Supplier>> watchSuppliers(String uid) => _col(uid)
      .orderBy('routeOrder')
      .snapshots()
      .map((s) => s.docs.map(Supplier.fromFirestore).toList());

  Stream<List<Supplier>> watchActiveSuppliers(String uid) => _col(uid)
      .where('isActive', isEqualTo: true)
      .orderBy('routeOrder')
      .snapshots()
      .map((s) => s.docs.map(Supplier.fromFirestore).toList());

  Future<List<Supplier>> getActiveSuppliers(String uid) async {
    final snap = await _col(uid)
        .where('isActive', isEqualTo: true)
        .orderBy('routeOrder')
        .get();
    return snap.docs.map(Supplier.fromFirestore).toList();
  }

  Future<String> addSupplier(String uid, Supplier supplier) async {
    final ref = await _col(uid).add(supplier.toFirestore());
    return ref.id;
  }

  Future<void> updateSupplier(
          String uid, String id, Map<String, dynamic> data) =>
      _col(uid).doc(id).update(data);

  Future<void> deleteSupplier(String uid, String id) =>
      _col(uid).doc(id).delete();

  Future<int> getMaxRouteOrder(String uid) async {
    final snap =
        await _col(uid).orderBy('routeOrder', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return 0;
    return (snap.docs.first.data() as Map<String, dynamic>)['routeOrder']
            as int? ??
        0;
  }

  Future<void> bulkUpdateRouteOrder(
      String uid, Map<String, int> updates) async {
    final batch = _db.batch();
    updates.forEach((id, order) {
      batch.update(_col(uid).doc(id), {'routeOrder': order});
    });
    await batch.commit();
  }
}
