import 'package:formz/formz.dart';

enum PasswordValidationError { empty, invalid, requireUpperAndLowercaseNumAnd8min }

enum ConfirmedPasswordValidationError { empty, invalid }

bool validatePassword(String value) {
  String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');

  const Password.dirty([String value = '']) : super.dirty(value);

  @override
  PasswordValidationError? validator(String? value) {
    if (value?.isNotEmpty != true) {
      return PasswordValidationError.empty;
    } else if (validatePassword(value!) == false) {
      return PasswordValidationError.requireUpperAndLowercaseNumAnd8min;
    }
    return null;
  }
}

class ConfirmedPassword extends FormzInput<String, ConfirmedPasswordValidationError> {
  const ConfirmedPassword.pure({this.password = ''}) : super.pure('');

  const ConfirmedPassword.dirty({required this.password, String value = ''}) : super.dirty(value);
  final String password;

  @override
  ConfirmedPasswordValidationError? validator(String? value) {
    return password == value ? null : ConfirmedPasswordValidationError.invalid;
  }
}
