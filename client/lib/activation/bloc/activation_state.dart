part of 'activation_bloc.dart';

// Define input validation errors
enum ActivationCodeInputError { empty }

// Extend FormzInput and provide the input type and error type.
class ActivationCode extends FormzInput<String, ActivationCodeInputError> {
  const ActivationCode.pure() : super.pure('');

  const ActivationCode.dirty([String value = '']) : super.dirty(value);

  @override
  ActivationCodeInputError? validator(String? value) {
    if (value?.isNotEmpty != true) {
      return ActivationCodeInputError.empty;
    }
    return null;
  }
}

class ActivationState extends Equatable {
  const ActivationState({
    this.status = FormzStatus.pure,
    this.email = "",
    this.password = "",
    this.activationCode = const ActivationCode.pure(),
    this.message = "",
    this.type = "",
  });

  final FormzStatus status;
  final String email;
  final String password;
  final ActivationCode activationCode;
  final String message;
  final String type;

  ActivationState copyWith({
    FormzStatus? status,
    String? email,
    String? password,
    ActivationCode? activationCode,
    String? message,
    String? type,
  }) {
    return ActivationState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      activationCode: activationCode ?? this.activationCode,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }

  @override
  List<Object> get props => [status, email, password, activationCode, message, type];
}
