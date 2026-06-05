import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/auth_repo.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepo _authRepo;

  ForgotPasswordCubit(this._authRepo)
      : super(const ForgotPasswordInitial());

  Future<void> sendReset(String email) async {
    if (email.trim().isEmpty) {
      emit(const ForgotPasswordError('auth_enter_email'));
      return;
    }
    emit(const ForgotPasswordLoading());
    try {
      await _authRepo.sendPasswordReset(email);
      emit(const ForgotPasswordSent());
    } catch (_) {
      emit(const ForgotPasswordError('auth_reset_failed'));
    }
  }
}
