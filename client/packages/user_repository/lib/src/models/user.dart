import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(this.id, this.email, this.fullname, this.username, this.image, this.login_counts);

  final String id;
  final String email;
  final String fullname;
  final String username;
  final String image;
  final int login_counts;

  @override
  List<Object> get props => [id,email,fullname,username,image,login_counts];

  static const empty = User('-','-','-','-','-',-1);
}
