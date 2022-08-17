part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class AccountSubmitted extends AccountEvent {
  final User user;

  const AccountSubmitted(this.user);
}
class AccountDelete extends AccountEvent {
  final User user;

  const AccountDelete(this.user);
}
