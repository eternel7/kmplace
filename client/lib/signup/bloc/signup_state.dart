part of 'signup_bloc.dart';

class SignupState extends Equatable {
  const SignupState({
    this.status = FormzStatus.pure,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmedPassword.pure(),
    this.message = "",
    this.type = "",
  });

  final FormzStatus status;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmPassword;
  final String message;
  final String type;

  SignupState copyWith({
    FormzStatus? status,
    Email? email,
    Password? password,
    ConfirmedPassword? confirmPassword,
    String? message,
    String? type,
  }) {
    return SignupState(
        status: status ?? this.status,
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        message: message ?? this.message,
        type: type ?? this.type);
  }

  @override
  List<Object> get props => [status, email, password, confirmPassword, message, type];
}
