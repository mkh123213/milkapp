abstract class WeightEntryState {
  const WeightEntryState();
}

class WeightEntryInitial extends WeightEntryState {
  const WeightEntryInitial();
}

class WeightEntrySaving extends WeightEntryState {
  const WeightEntrySaving();
}

class WeightEntrySaved extends WeightEntryState {
  const WeightEntrySaved();
}

class WeightEntryError extends WeightEntryState {
  final String errorKey;
  const WeightEntryError(this.errorKey);
}
