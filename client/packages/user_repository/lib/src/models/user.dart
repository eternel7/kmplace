import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(this.id, this.email, this.username, this.fullname,  this.image, this.login_counts);

  final String id;
  final String email;
  final String username;
  final String fullname;
  final String image;
  final int login_counts;

  @override
  List<Object> get props => [id,email,username,fullname,image,login_counts];

  static const empty = User('-','-','-','-','-',-1);
}
