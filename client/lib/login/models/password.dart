import 'package:formz/formz.dart';

enum PasswordValidationError {
  empty,
  invalid,
  requireUpperAndLowercaseNumAnd8min
}

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
