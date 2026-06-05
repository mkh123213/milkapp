import '../data_source/settings_data_source.dart';

class SettingsRepo {
  final SettingsDataSource _ds;

  SettingsRepo(this._ds);

  bool getOnboarded() => _ds.getOnboarded();
  Future<void> setOnboarded(bool value) => _ds.setOnboarded(value);
}
