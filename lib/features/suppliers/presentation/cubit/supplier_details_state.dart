import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';

class SupplierDetailsState {
  final Supplier? supplier;
  final MilkEntry? todayEntry;
  final List<MilkEntry> entries;
  final DateTime selectedMonth;
  final bool loading;

  SupplierDetailsState({
    this.supplier,
    this.todayEntry,
    this.entries = const [],
    DateTime? selectedMonth,
    this.loading = true,
  }) : selectedMonth = selectedMonth ??
            DateTime(DateTime.now().year, DateTime.now().month);

  SupplierDetailsState copyWith({
    Supplier? supplier,
    MilkEntry? todayEntry,
    List<MilkEntry>? entries,
    DateTime? selectedMonth,
    bool? loading,
  }) =>
      SupplierDetailsState(
        supplier: supplier ?? this.supplier,
        todayEntry: todayEntry ?? this.todayEntry,
        entries: entries ?? this.entries,
        selectedMonth: selectedMonth ?? this.selectedMonth,
        loading: loading ?? this.loading,
      );
}
