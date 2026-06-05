import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;

  AuthRemoteDataSource(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  String get currentUserEmail => _auth.currentUser?.email ?? '';

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<UserCredential> createAccount(String email, String password) =>
      _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  String mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'auth_invalid_credentials';
      case 'user-disabled':
        return 'auth_user_disabled';
      case 'too-many-requests':
        return 'auth_too_many_requests';
      case 'network-request-failed':
        return 'auth_network_error';
      case 'email-already-in-use':
        return 'auth_email_in_use';
      case 'weak-password':
        return 'auth_weak_password';
      case 'invalid-email':
        return 'auth_invalid_email';
      default:
        return 'error_generic';
    }
  }
}
