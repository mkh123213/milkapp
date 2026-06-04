import '../../../../shared/models/weekly_report.dart';
import '../data_source/reports_remote_data_source.dart';

class ReportsRepo {
  final ReportsRemoteDataSource _ds;

  ReportsRepo(this._ds);

  Stream<List<WeeklyReport>> watchReports(String uid) => _ds.watchReports(uid);

  Future<WeeklyReport?> getReportForWeek(String uid, String weekKey) =>
      _ds.getReportForWeek(uid, weekKey);

  Future<String> createReport(String uid, WeeklyReport report) =>
      _ds.createReport(uid, report);

  Future<void> updateReport(String uid, String id, Map<String, dynamic> data) =>
      _ds.updateReport(uid, id, data);

  Future<void> refreshReportStats(String uid, String reportId, String weekKey, int activeSupplierCount) =>
      _ds.refreshReportStats(uid, reportId, weekKey, activeSupplierCount);
}
