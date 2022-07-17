part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = FormzStatus.pure,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.message = "",
    this.type = "",
  });

  final FormzStatus status;
  final Email email;
  final Password password;
  final String message;
  final String type;

  LoginState copyWith({
    FormzStatus? status,
    Email? email,
    Password? password,
    String? message,
    String? type,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }

  @override
  List<Object> get props => [status, email, password, message, type];
}
