import 'package:formz/formz.dart';

enum UsernameValidationError {
  empty,
  invalid,
}

class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure() : super.pure('');
  const Username.dirty([String value = '']) : super.dirty(value);

  @override
  UsernameValidationError? validator(String? value) {
    if(value?.isNotEmpty != true) {
      return UsernameValidationError.empty;
    } else if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!) != true) {
      return UsernameValidationError.invalid;
    }
    return null;
  }
}
