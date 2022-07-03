import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(this.id, this.email, this.fullname, this.username, this.login_counts);

  final String id;
  final String email;
  final String fullname;
  final String username;
  final int login_counts;

  @override
  List<Object> get props => [id,email,fullname,username,login_counts];

  static const empty = User('-','-','-','-',-1);
}
