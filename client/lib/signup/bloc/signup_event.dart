part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class SignupUsernameChanged extends SignupEvent {
  const SignupUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

class SignupPasswordChanged extends SignupEvent {
  const SignupPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class SignupConfirmPasswordChanged extends SignupEvent {
  const SignupConfirmPasswordChanged(this.confirmPassword);

  final String confirmPassword;

  @override
  List<Object> get props => [confirmPassword];
}

class SignupSubmitted extends SignupEvent {
  const SignupSubmitted();
}
