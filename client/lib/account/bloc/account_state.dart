part of 'account_bloc.dart';

class AccountState extends Equatable {
  const AccountState({
    this.status = FormzStatus.valid,
    this.user = User.empty,
    this.username = const SimpleString.pure(),
    this.fullname = const SimpleString.pure(),
    this.image = const SimpleString.pure(),
    this.message = "",
    this.type = "",
  });

  final FormzStatus status;
  final User user;
  final SimpleString username;
  final SimpleString fullname;
  final SimpleString image;
  final String message;
  final String type;

  AccountState copyWith({
    FormzStatus? status,
    User? user,
    SimpleString? username,
    SimpleString? fullname,
    SimpleString? image,
    String? message,
    String? type,
  }) {
    return AccountState(
      status: status ?? this.status,
      user: user ?? this.user,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      image: image ?? this.image,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }

  @override
  List<Object> get props => [status, user, username, fullname, image, message, type];
}
