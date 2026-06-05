import '../../../../shared/models/supplier.dart';

class RouteOrderingState {
  final List<Supplier> ordered;
  final int changeCount;
  final bool saving;
  final bool saved;

  const RouteOrderingState({
    this.ordered = const [],
    this.changeCount = 0,
    this.saving = false,
    this.saved = false,
  });

  RouteOrderingState copyWith({
    List<Supplier>? ordered,
    int? changeCount,
    bool? saving,
    bool? saved,
  }) =>
      RouteOrderingState(
        ordered: ordered ?? this.ordered,
        changeCount: changeCount ?? this.changeCount,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
      );
}
