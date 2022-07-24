part of 'forgottenpassword_bloc.dart';

// Define input validation errors
enum ForgottenPasswordCodeInputError { empty }

// Extend FormzInput and provide the input type and error type.
class ForgottenPasswordCode extends FormzInput<String, ForgottenPasswordCodeInputError> {
  const ForgottenPasswordCode.pure() : super.pure('');

  const ForgottenPasswordCode.dirty([String value = '']) : super.dirty(value);

  @override
  ForgottenPasswordCodeInputError? validator(String? value) {
    if (value?.isNotEmpty != true) {
      return ForgottenPasswordCodeInputError.empty;
    }
    return null;
  }
}

class ForgottenPasswordState extends Equatable {
  const ForgottenPasswordState({
    this.status = FormzStatus.pure,
    this.email = const Email.pure(),
    this.forgottenPasswordCode = const ForgottenPasswordCode.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmedPassword.pure(),
    this.message = "",
    this.type = "",
  });

  final FormzStatus status;
  final Email email;
  final ForgottenPasswordCode forgottenPasswordCode;
  final Password password;
  final ConfirmedPassword confirmPassword;
  final String message;
  final String type;

  ForgottenPasswordState copyWith({
    FormzStatus? status,
    Email? email,
    ForgottenPasswordCode? forgottenPasswordCode,
    Password? password,
    ConfirmedPassword? confirmPassword,
    String? message,
    String? type,
  }) {
    return ForgottenPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      forgottenPasswordCode: forgottenPasswordCode ?? this.forgottenPasswordCode,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }

  @override
  List<Object> get props => [status, email, forgottenPasswordCode, password, confirmPassword, message, type];
}
