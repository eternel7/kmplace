part of 'signup_bloc.dart';

class SignupState extends Equatable {
  const SignupState({
    this.status = FormzStatus.pure,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmedPassword.pure(),
  });

  final FormzStatus status;
  final Username username;
  final Password password;
  final ConfirmedPassword confirmPassword;

  SignupState copyWith({
    FormzStatus? status,
    Username? username,
    Password? password,
    ConfirmedPassword? confirmPassword,
  }) {
    return SignupState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword
    );
  }

  @override
  List<Object> get props => [status, username, password, confirmPassword];
}
