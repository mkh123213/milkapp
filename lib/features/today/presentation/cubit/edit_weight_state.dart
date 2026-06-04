import '../../../../shared/models/milk_entry.dart';

abstract class EditWeightState {
  const EditWeightState();
}

class EditWeightLoading extends EditWeightState {
  const EditWeightLoading();
}

class EditWeightLoaded extends EditWeightState {
  final MilkEntry entry;
  const EditWeightLoaded(this.entry);
}

class EditWeightSaving extends EditWeightState {
  final MilkEntry entry;
  const EditWeightSaving(this.entry);
}

class EditWeightSaved extends EditWeightState {
  const EditWeightSaved();
}

class EditWeightError extends EditWeightState {
  final String errorKey;
  const EditWeightError(this.errorKey);
}
