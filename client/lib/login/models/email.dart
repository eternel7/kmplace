import 'package:formz/formz.dart';

enum EmailValidationError {
  empty,
  invalid,
}

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');
  const Email.dirty([String value = '']) : super.dirty(value);

  @override
  EmailValidationError? validator(String? value) {
    if(value?.isNotEmpty != true) {
      return EmailValidationError.empty;
    } else if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!) != true) {
      return EmailValidationError.invalid;
    }
    return null;
  }
}
