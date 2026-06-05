import '../../../../shared/models/weekly_report.dart';
import '../../../../shared/models/milk_entry.dart';
import '../../../../shared/models/supplier.dart';

class ReportDetailsState {
  final WeeklyReport? report;
  final List<MilkEntry> entries;
  final List<Supplier> suppliers;
  final bool loading;
  final bool finalizing;

  const ReportDetailsState({
    this.report,
    this.entries = const [],
    this.suppliers = const [],
    this.loading = true,
    this.finalizing = false,
  });

  ReportDetailsState copyWith({
    WeeklyReport? report,
    List<MilkEntry>? entries,
    List<Supplier>? suppliers,
    bool? loading,
    bool? finalizing,
  }) =>
      ReportDetailsState(
        report: report ?? this.report,
        entries: entries ?? this.entries,
        suppliers: suppliers ?? this.suppliers,
        loading: loading ?? this.loading,
        finalizing: finalizing ?? this.finalizing,
      );
}
