abstract class ForgotPasswordState {
  const ForgotPasswordState();
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSent extends ForgotPasswordState {
  const ForgotPasswordSent();
}

class ForgotPasswordError extends ForgotPasswordState {
  final String errorKey;
  const ForgotPasswordError(this.errorKey);
}
