import 'package:formz/formz.dart';

enum SimpleStringValidationError {
  invalid,
}

class SimpleString extends FormzInput<String, SimpleStringValidationError> {
  const SimpleString.pure() : super.pure('');
  const SimpleString.dirty([String value = '']) : super.dirty(value);

  @override
  SimpleStringValidationError? validator(String? value) {
    return null;
  }
}