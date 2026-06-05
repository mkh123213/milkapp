import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/auth_repo.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final AuthRepo _authRepo;

  SignupCubit(this._authRepo) : super(const SignupInitial());

  Future<void> signup(
      String email, String password, String confirmPassword) async {
    if (email.trim().isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      emit(const SignupError('auth_fill_all_fields'));
      return;
    }
    if (password.length < 8) {
      emit(const SignupError('auth_password_min_8'));
      return;
    }
    if (password != confirmPassword) {
      emit(const SignupError('auth_password_mismatch'));
      return;
    }
    emit(const SignupLoading());
    try {
      await _authRepo.createAccount(email, password);
      emit(const SignupSuccess());
    } on FirebaseAuthException catch (e) {
      emit(SignupError(_authRepo.mapAuthError(e)));
    }
  }
}
