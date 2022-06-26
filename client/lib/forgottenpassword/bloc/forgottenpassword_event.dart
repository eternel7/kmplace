part of 'forgottenpassword_bloc.dart';

abstract class ForgottenPasswordEvent extends Equatable {
  const ForgottenPasswordEvent();

  @override
  List<Object> get props => [];
}

class ForgottenPasswordEmailChanged extends ForgottenPasswordEvent {
  const ForgottenPasswordEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class ForgottenPasswordSubmitted extends ForgottenPasswordEvent {
  const ForgottenPasswordSubmitted();
}
