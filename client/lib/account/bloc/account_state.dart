part of 'account_bloc.dart';

class AccountState extends Equatable {
  const AccountState({
    this.status = FormzStatus.pure,
    this.email = "",
    this.username = "",
    this.fullname = "",
    this.message = "",
    this.type = "",
  });

  final FormzStatus status;
  final String email;
  final String username;
  final String fullname;
  final String message;
  final String type;

  AccountState copyWith({
    FormzStatus? status,
    String? email,
    String? username,
    String? fullname,
    String? message,
    String? type,
  }) {
    return AccountState(
      status: status ?? this.status,
      email: email ?? this.email,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }

  @override
  List<Object> get props => [status, email, username, fullname, message, type];
}
