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

class WeightEntryUndoing extends WeightEntryState {
  const WeightEntryUndoing();
}

class WeightEntryUndone extends WeightEntryState {
  const WeightEntryUndone();
}

class WeightEntryError extends WeightEntryState {
  final String errorKey;
  const WeightEntryError(this.errorKey);
}
