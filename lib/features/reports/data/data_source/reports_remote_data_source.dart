import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/weekly_report.dart';
import '../../../../shared/models/milk_entry.dart';

class ReportsRemoteDataSource {
  final FirebaseFirestore _db;

  ReportsRemoteDataSource(this._db);

  CollectionReference _reportCol(String uid) =>
      _db.collection('users').doc(uid).collection('weekly_reports');

  CollectionReference _entryCol(String uid) =>
      _db.collection('users').doc(uid).collection('milk_entries');

  Stream<List<WeeklyReport>> watchReports(String uid) => _reportCol(uid)
      .orderBy('weekStartDate', descending: true)
      .snapshots()
      .map((s) => s.docs.map(WeeklyReport.fromFirestore).toList());

  Future<WeeklyReport?> getReportForWeek(String uid, String weekKey) async {
    final snap = await _reportCol(uid).where('weekKey', isEqualTo: weekKey).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return WeeklyReport.fromFirestore(snap.docs.first);
  }

  Future<String> createReport(String uid, WeeklyReport report) async {
    final ref = await _reportCol(uid).add(report.toFirestore());
    return ref.id;
  }

  Future<void> updateReport(String uid, String id, Map<String, dynamic> data) =>
      _reportCol(uid).doc(id).update(data);

  Future<void> deleteReport(String uid, String id) =>
      _reportCol(uid).doc(id).delete();

  Future<void> refreshReportStats(String uid, String reportId, String weekKey, int activeSupplierCount) async {
    final snap = await _entryCol(uid).where('weekKey', isEqualTo: weekKey).get();
    final entries = snap.docs.map(MilkEntry.fromFirestore).toList();
    final totalWeight = entries.where((e) => e.entryStatus == EntryStatus.recorded).fold(0.0, (acc, e) => acc + (e.currentWeightKg ?? 0));
    final noMilkCount = entries.where((e) => e.entryStatus == EntryStatus.noMilk).length;
    final editedCount = entries.where((e) => e.isEdited).length;
    final recordedDays = entries.length;
    final expectedDays = activeSupplierCount * 7;
    final missingCount = expectedDays - recordedDays;
    await updateReport(uid, reportId, {
      'totalWeightKg': totalWeight,
      'missingEntriesCount': missingCount < 0 ? 0 : missingCount,
      'noMilkEntriesCount': noMilkCount,
      'editedEntriesCount': editedCount,
      'supplierCount': activeSupplierCount,
    });
  }
}
