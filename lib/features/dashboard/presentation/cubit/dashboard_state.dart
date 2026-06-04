import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';
import '../../data/models/dashboard_stats.dart';

class DashboardState {
  final List<Supplier> suppliers;
  final Map<String, MilkEntry> entriesMap;
  final DashboardStats stats;
  final List<Supplier> absentSuppliers;
  final bool loading;

  DashboardState({
    this.suppliers = const [],
    this.entriesMap = const {},
    DashboardStats? stats,
    this.absentSuppliers = const [],
    this.loading = true,
  }) : stats = stats ??
            const DashboardStats(
              totalSuppliers: 0,
              receivedToday: 0,
              pendingToday: 0,
              noMilkToday: 0,
              editedToday: 0,
              todayWeight: 0,
              weekWeight: 0,
            );

  DashboardState copyWith({
    List<Supplier>? suppliers,
    Map<String, MilkEntry>? entriesMap,
    DashboardStats? stats,
    List<Supplier>? absentSuppliers,
    bool? loading,
  }) =>
      DashboardState(
        suppliers: suppliers ?? this.suppliers,
        entriesMap: entriesMap ?? this.entriesMap,
        stats: stats ?? this.stats,
        absentSuppliers: absentSuppliers ?? this.absentSuppliers,
        loading: loading ?? this.loading,
      );
}
