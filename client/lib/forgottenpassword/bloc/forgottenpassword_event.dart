part of 'forgottenpassword_bloc.dart';

abstract class ForgottenPasswordEvent extends Equatable {
  const ForgottenPasswordEvent();

  @override
  List<Object> get props => [];
}

class ForgottenPasswordEmailChanged extends ForgottenPasswordEvent {
  const ForgottenPasswordEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class ForgottenPasswordCodeChanged extends ForgottenPasswordEvent {
  const ForgottenPasswordCodeChanged(this.forgottenPasswordCode);

  final String forgottenPasswordCode;

  @override
  List<Object> get props => [forgottenPasswordCode];
}

class ForgottenPasswordPasswordChanged extends ForgottenPasswordEvent {
  const ForgottenPasswordPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class ForgottenPasswordConfirmPasswordChanged extends ForgottenPasswordEvent {
  const ForgottenPasswordConfirmPasswordChanged(this.confirmPassword);

  final String confirmPassword;

  @override
  List<Object> get props => [confirmPassword];
}

class ForgottenPasswordAskCode extends ForgottenPasswordEvent {
  const ForgottenPasswordAskCode();
}

class ForgottenPasswordSubmitted extends ForgottenPasswordEvent {
  const ForgottenPasswordSubmitted();
}

