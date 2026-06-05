import '../../../../shared/models/weekly_report.dart';

abstract class ReportsListState {
  const ReportsListState();
}

class ReportsListLoading extends ReportsListState {
  const ReportsListLoading();
}

class ReportsListLoaded extends ReportsListState {
  final List<WeeklyReport> reports;
  const ReportsListLoaded(this.reports);
}

class ReportsListCreating extends ReportsListState {
  final List<WeeklyReport> reports;
  const ReportsListCreating(this.reports);
}

class ReportsListError extends ReportsListState {
  final String errorKey;
  const ReportsListError(this.errorKey);
}
