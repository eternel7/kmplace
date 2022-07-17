part of 'activation_bloc.dart';

abstract class ActivationEvent extends Equatable {
  const ActivationEvent();

  @override
  List<Object> get props => [];
}

class ActivationCodeChanged extends ActivationEvent {
  const ActivationCodeChanged(this.activationCode);

  final String activationCode;

  @override
  List<Object> get props => [activationCode];
}

class ActivationSubmitted extends ActivationEvent {
  final String email;
  final String password;

  const ActivationSubmitted(this.email, this.password);
}
class ActivationSend extends ActivationEvent {
  final String email;
  final String password;

  const ActivationSend(this.email, this.password);
}
