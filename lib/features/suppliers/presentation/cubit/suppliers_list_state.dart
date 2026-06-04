import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';

class SuppliersListState {
  final List<Supplier> allSuppliers;
  final List<Supplier> filteredSuppliers;
  final List<MilkEntry> weeklyEntries;
  final String search;
  final String filterMode;
  final bool loading;
  final String? error;

  const SuppliersListState({
    this.allSuppliers = const [],
    this.filteredSuppliers = const [],
    this.weeklyEntries = const [],
    this.search = '',
    this.filterMode = 'all',
    this.loading = true,
    this.error,
  });

  SuppliersListState copyWith({
    List<Supplier>? allSuppliers,
    List<Supplier>? filteredSuppliers,
    List<MilkEntry>? weeklyEntries,
    String? search,
    String? filterMode,
    bool? loading,
    String? error,
  }) =>
      SuppliersListState(
        allSuppliers: allSuppliers ?? this.allSuppliers,
        filteredSuppliers: filteredSuppliers ?? this.filteredSuppliers,
        weeklyEntries: weeklyEntries ?? this.weeklyEntries,
        search: search ?? this.search,
        filterMode: filterMode ?? this.filterMode,
        loading: loading ?? this.loading,
        error: error,
      );
}
