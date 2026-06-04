import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/milk_entry.dart';

class TodayRemoteDataSource {
  final FirebaseFirestore _db;

  TodayRemoteDataSource(this._db);

  CollectionReference _col(String uid) =>
      _db.collection('users').doc(uid).collection('milk_entries');

  Stream<List<MilkEntry>> watchEntriesForDate(String uid, String dateKey) =>
      _col(uid)
          .where('dateKey', isEqualTo: dateKey)
          .snapshots()
          .map((s) => s.docs.map(MilkEntry.fromFirestore).toList());

  Stream<List<MilkEntry>> watchEntriesForWeek(String uid, String weekKey) =>
      _col(uid)
          .where('weekKey', isEqualTo: weekKey)
          .snapshots()
          .map((s) => s.docs.map(MilkEntry.fromFirestore).toList());

  Future<List<MilkEntry>> getEntriesForSupplier(
      String uid, String supplierId, DateTime from, DateTime to) async {
    final snap = await _col(uid)
        .where('supplierId', isEqualTo: supplierId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map(MilkEntry.fromFirestore).toList();
  }

  Future<MilkEntry?> getEntryForDate(
      String uid, String supplierId, String dateKey) async {
    final snap = await _col(uid)
        .where('supplierId', isEqualTo: supplierId)
        .where('dateKey', isEqualTo: dateKey)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return MilkEntry.fromFirestore(snap.docs.first);
  }

  Future<MilkEntry?> getEntryById(String uid, String entryId) async {
    final doc = await _col(uid).doc(entryId).get();
    if (!doc.exists) return null;
    return MilkEntry.fromFirestore(doc);
  }

  Future<String> addEntry(String uid, MilkEntry entry) async {
    final ref = await _col(uid).add(entry.toFirestore());
    return ref.id;
  }

  Future<void> updateEntry(
          String uid, String id, Map<String, dynamic> data) =>
      _col(uid).doc(id).update(data);

  Future<void> deleteEntry(String uid, String id) =>
      _col(uid).doc(id).delete();
}
