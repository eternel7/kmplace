part of 'forgottenpassword_bloc.dart';

class ForgottenPasswordState extends Equatable {
  const ForgottenPasswordState({
    this.status = FormzStatus.pure,
    this.email = const Username.pure(),
  });

  final FormzStatus status;
  final Username email;

  ForgottenPasswordState copyWith({
    FormzStatus? status,
    Username? email,
  }) {
    return ForgottenPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
    );
  }

  @override
  List<Object> get props => [status, email];
}
