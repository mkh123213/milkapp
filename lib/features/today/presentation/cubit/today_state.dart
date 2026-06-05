import '../../../../shared/models/supplier.dart';
import '../../../../shared/models/milk_entry.dart';

class TodayState {
  final List<Supplier> suppliers;
  final Map<String, MilkEntry> entriesMap;
  final List<Supplier> pendingList;
  final List<Supplier> receivedList;
  final List<Supplier> noMilkList;
  final double totalToday;
  final bool isWeekLocked;
  final String search;
  final String? villageFilter;
  final bool loading;

  const TodayState({
    this.suppliers = const [],
    this.entriesMap = const {},
    this.pendingList = const [],
    this.receivedList = const [],
    this.noMilkList = const [],
    this.totalToday = 0,
    this.isWeekLocked = false,
    this.search = '',
    this.villageFilter,
    this.loading = true,
  });

  TodayState copyWith({
    List<Supplier>? suppliers,
    Map<String, MilkEntry>? entriesMap,
    List<Supplier>? pendingList,
    List<Supplier>? receivedList,
    List<Supplier>? noMilkList,
    double? totalToday,
    bool? isWeekLocked,
    String? search,
    String? villageFilter,
    bool clearVillageFilter = false,
    bool? loading,
  }) =>
      TodayState(
        suppliers: suppliers ?? this.suppliers,
        entriesMap: entriesMap ?? this.entriesMap,
        pendingList: pendingList ?? this.pendingList,
        receivedList: receivedList ?? this.receivedList,
        noMilkList: noMilkList ?? this.noMilkList,
        totalToday: totalToday ?? this.totalToday,
        isWeekLocked: isWeekLocked ?? this.isWeekLocked,
        search: search ?? this.search,
        villageFilter: clearVillageFilter ? null : (villageFilter ?? this.villageFilter),
        loading: loading ?? this.loading,
      );
}
