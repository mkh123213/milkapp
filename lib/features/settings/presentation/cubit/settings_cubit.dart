import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/repos/auth_repo.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final AuthRepo _authRepo;

  SettingsCubit(this._authRepo)
      : super(const SettingsInitial());

  String? get userDisplayName => _authRepo.currentUser?.displayName;
  String get userEmail => _authRepo.currentUserEmail;

  Future<void> logout() async {
    emit(const SettingsLoggingOut());
    await _authRepo.signOut();
    emit(const SettingsLoggedOut());
  }
}
