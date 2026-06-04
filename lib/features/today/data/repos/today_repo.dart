import '../../../../shared/models/milk_entry.dart';
import '../data_source/today_remote_data_source.dart';

class TodayRepo {
  final TodayRemoteDataSource _ds;

  TodayRepo(this._ds);

  Stream<List<MilkEntry>> watchEntriesForDate(String uid, String dateKey) =>
      _ds.watchEntriesForDate(uid, dateKey);

  Stream<List<MilkEntry>> watchEntriesForWeek(String uid, String weekKey) =>
      _ds.watchEntriesForWeek(uid, weekKey);

  Future<List<MilkEntry>> getEntriesForSupplier(
          String uid, String supplierId, DateTime from, DateTime to) =>
      _ds.getEntriesForSupplier(uid, supplierId, from, to);

  Future<MilkEntry?> getEntryForDate(
          String uid, String supplierId, String dateKey) =>
      _ds.getEntryForDate(uid, supplierId, dateKey);

  Future<MilkEntry?> getEntryById(String uid, String entryId) =>
      _ds.getEntryById(uid, entryId);

  Future<String> addEntry(String uid, MilkEntry entry) =>
      _ds.addEntry(uid, entry);

  Future<void> updateEntry(
          String uid, String id, Map<String, dynamic> data) =>
      _ds.updateEntry(uid, id, data);

  Future<void> deleteEntry(String uid, String id) =>
      _ds.deleteEntry(uid, id);
}
