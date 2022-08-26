part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class AccountUsernameChanged extends AccountEvent {
  const AccountUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

class AccountFullnameChanged extends AccountEvent {
  const AccountFullnameChanged(this.fullname);

  final String fullname;

  @override
  List<Object> get props => [fullname];
}

class AccountImageChanged extends AccountEvent {
  const AccountImageChanged(this.image);

  final String image;

  @override
  List<Object> get props => [image];
}

class AccountSubmitted extends AccountEvent {
  final User user;

  const AccountSubmitted(this.user);
}

class AccountDelete extends AccountEvent {
  final User user;

  const AccountDelete(this.user);
}
