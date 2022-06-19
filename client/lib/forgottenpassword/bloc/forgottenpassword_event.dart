part of 'forgottenpassword_bloc.dart';

abstract class ForgottenPasswordEvent extends Equatable {
  const ForgottenPasswordEvent();

  @override
  List<Object> get props => [];
}

class ForgottenPasswordUsernameChanged extends ForgottenPasswordEvent {
  const ForgottenPasswordUsernameChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class ForgottenPasswordSubmitted extends ForgottenPasswordEvent {
  const ForgottenPasswordSubmitted();
}
