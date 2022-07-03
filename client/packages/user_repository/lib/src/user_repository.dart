import 'dart:async';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/models.dart';

class UserRepository {
  User? _user;

  Future<User?> getUser() async {
    if (_user != null) return _user;
    final prefs = await SharedPreferences.getInstance();
    var response = prefs.getString('login_response');
    if (response is String) {
      var jsonResponse = convert.jsonDecode(response) as Map<String, dynamic>;
      var u = jsonResponse['data']['user'];;
      _user = User(u['email'], u['email'],
          (u['fullname'] is String) ? u['fullname'] : '-',
          (u['username'] is String) ? u['username'] : '-',
          (u['login_counts'] is int) ? u['login_counts'] : -1);
      print(_user);
    }
    return _user;
  }
}
