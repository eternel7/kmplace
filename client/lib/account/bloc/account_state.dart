part of 'account_bloc.dart';

class AccountState extends Equatable {
  const AccountState({
    this.status = FormzStatus.valid,
    this.username = const SimpleString.pure(),
    this.fullname = const SimpleString.pure(),
    this.image = const SimpleString.pure(),
    this.message = "",
    this.type = "",
  });

  final FormzStatus status;
  final SimpleString username;
  final SimpleString fullname;
  final SimpleString image;
  final String message;
  final String type;

  AccountState copyWith({
    FormzStatus? status,
    SimpleString? username,
    SimpleString? fullname,
    SimpleString? image,
    String? message,
    String? type,
  }) {
    return AccountState(
      status: status ?? this.status,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      image: image ?? this.image,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }

  @override
  List<Object> get props => [status, username, fullname, image, message, type];
}
