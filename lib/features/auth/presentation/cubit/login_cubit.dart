import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/auth_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo _authRepo;

  LoginCubit(this._authRepo) : super(const LoginInitial());

  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      emit(const LoginError('auth_enter_email_password'));
      return;
    }
    emit(const LoginLoading());
    try {
      await _authRepo.signIn(email, password);
      emit(const LoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(LoginError(_authRepo.mapAuthError(e)));
    }
  }
}
