part of 'signup_bloc.dart';

class SignupState extends Equatable {
  const SignupState({
    this.status = FormzStatus.pure,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmedPassword.pure(),
  });

  final FormzStatus status;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmPassword;

  SignupState copyWith({
    FormzStatus? status,
    Email? email,
    Password? password,
    ConfirmedPassword? confirmPassword,
  }) {
    return SignupState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword
    );
  }

  @override
  List<Object> get props => [status, email, password, confirmPassword];
}
