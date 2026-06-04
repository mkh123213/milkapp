import 'package:shared_preferences/shared_preferences.dart';

class SettingsDataSource {
  final SharedPreferences _prefs;

  SettingsDataSource(this._prefs);

  bool getOnboarded() => _prefs.getBool('onboarded') ?? false;
  Future<void> setOnboarded(bool value) => _prefs.setBool('onboarded', value);
}
