part of 'forgottenpassword_bloc.dart';

class ForgottenPasswordState extends Equatable {
  const ForgottenPasswordState({
    this.status = FormzStatus.pure,
    this.email = const Email.pure(),
  });

  final FormzStatus status;
  final Email email;

  ForgottenPasswordState copyWith({
    FormzStatus? status,
    Email? email,
  }) {
    return ForgottenPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
    );
  }

  @override
  List<Object> get props => [status, email];
}
