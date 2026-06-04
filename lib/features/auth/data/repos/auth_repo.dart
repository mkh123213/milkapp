import 'package:firebase_auth/firebase_auth.dart';
import '../data_source/auth_remote_data_source.dart';

class AuthRepo {
  final AuthRemoteDataSource _ds;

  AuthRepo(this._ds);

  Stream<User?> get authStateChanges => _ds.authStateChanges;
  User? get currentUser => _ds.currentUser;
  String? get currentUserId => _ds.currentUserId;
  String get currentUserEmail => _ds.currentUserEmail;

  Future<UserCredential> signIn(String email, String password) =>
      _ds.signInWithEmail(email, password);

  Future<UserCredential> createAccount(String email, String password) =>
      _ds.createAccount(email, password);

  Future<void> signOut() => _ds.signOut();

  Future<void> sendPasswordReset(String email) =>
      _ds.sendPasswordReset(email);

  String mapAuthError(FirebaseAuthException e) => _ds.mapAuthError(e);
}
