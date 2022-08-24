import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class MsgException implements Exception {
  final String message;

  MsgException(this.message); // Pass your message in constructor.

  @override
  String toString() {
    return message;
  }
}

class ActivationException implements Exception {
  final String message;

  ActivationException(this.message); // Pass your message in constructor.

  @override
  String toString() {
    return message;
  }
}

class SettingException implements Exception {
  final String message;

  SettingException(this.message); // Pass your message in constructor.

  @override
  String toString() {
    return message;
  }
}

class ServiceException implements Exception {
  final String message;

  ServiceException(this.message); // Pass your message in constructor.

  @override
  String toString() {
    return message;
  }
}

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<Response> serverCall({required Map body, required String route}) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    String? backendUrl = prefs.getString('serviceUrl');
    if (backendUrl == null || backendUrl == "") {
      throw SettingException('Missing backendUrl');
    }
    return await http
        .post(Uri.http(backendUrl, route),
            headers: {"Access-Control-Allow-Origin": "*"}, body: body)
        .timeout(Duration(seconds: 5));
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    var response =
        await serverCall(body: {'email': email, 'password': password}, route: '/api/login');
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonResponse['status'] == true) {
        prefs.setString('login_response', response.body).then((bool success) {
          if (success) {
            prefs.setString('token', jsonResponse['data']['token']).then((bool success) {
              if (success) {
                _controller.add(AuthenticationStatus.authenticated);
              }
            });
          }
        });
      } else {
        if (jsonResponse['message'] == "Activation needed") {
          throw ActivationException(convert.json.encode({'email': email, 'password': password}));
        } else {
          throw MsgException(jsonResponse['message']);
        }
      }
    } else {
      throw ServiceException("Http error with status : ${response.statusCode}");
    }
  }

  Future<void> activate({
    required String email,
    required String password,
    required String activation_code,
  }) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    var response = await serverCall(
        body: {'email': email, 'password': password, 'activation_code': activation_code},
        route: '/api/activation');
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonResponse['status'] == true) {
        prefs.setString('login_response', response.body).then((bool success) {
          if (success) {
            prefs.setString('token', jsonResponse['data']['token']).then((bool success) {
              if (success) {
                _controller.add(AuthenticationStatus.authenticated);
              }
            });
          }
        });
      } else {
        throw ActivationException(jsonResponse['message']);
      }
    } else {
      throw ServiceException("Http error with status : ${response.statusCode}");
    }
  }

  Future<void> activationSend({required String email, required String password}) async {
    var response = await serverCall(
        body: {'email': email, 'password': password},
        route: '/api/activationsend');
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonResponse['status'] != true) {
        throw MsgException(jsonResponse['message']);
      }
    } else {
      throw ServiceException("Http error with status : ${response.statusCode}");
    }
  }

  Future<void> logOut() async {
    _controller.add(AuthenticationStatus.unauthenticated);
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    // Remove data from local storage.
    prefs.remove('login_response');
    prefs.remove('token');
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password == confirmPassword) {
      var response = await serverCall(
          body: {'email': email, 'password': password},
          route: '/api/register');
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['status'] == true) {
          logIn(email: email, password: password);
        } else {
          throw new MsgException('Missing backendUrl');
        }
      } else {
        throw ServiceException("Http error with status : ${response.statusCode}");
      }
    } else {
      throw new MsgException('incorrect password confirmation');
    }
  }

  Future<void> forgottenPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    if (password == confirmPassword) {
      var response = await serverCall(
          body: {'email': email, 'password': password, 'code': code},
          route: '/api/forgottenpassword');
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['status'] == true) {
          logIn(email: email, password: password);
        } else {
          throw ActivationException(jsonResponse['message']);
        }
      } else {
        throw ServiceException("Http error with status : ${response.statusCode}");
      }
    } else {
      throw new MsgException('incorrect password confirmation');
    }
  }

  Future<void> forgottenPasswordCodeSend({required String email}) async {
    var response = await serverCall(
        body: {'email': email},
        route: '/api/forgottenpasswordcode');
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonResponse['status'] != true) {
        throw MsgException(jsonResponse['message']);
      }
    } else {
      throw ServiceException("Http error with status : ${response.statusCode}");
    }
  }

  void dispose() => _controller.close();
}
