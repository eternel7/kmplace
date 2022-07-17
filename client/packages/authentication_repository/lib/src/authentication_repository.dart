import 'dart:async';
import 'dart:convert' as convert;
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

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    String? backendUrl = prefs.getString('serviceUrl');
    if (backendUrl == null || backendUrl == "") {
      throw SettingException('Missing backendUrl');
    }
    var response = await http.post(Uri.http(backendUrl, '/api/login'),
        headers: {"Access-Control-Allow-Origin": "*"},
        body: {'email': email, 'password': password});
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
    String? backendUrl = prefs.getString('serviceUrl');
    if (backendUrl == null || backendUrl == "") {
      throw SettingException('Missing backendUrl');
    }
    var response = await http.post(Uri.http(backendUrl, '/api/activation'),
        headers: {"Access-Control-Allow-Origin": "*"},
        body: {'email': email, 'password': password, 'activation_code': activation_code});
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
  }  Future<void> activationSend({
    required String email,
    required String password
  }) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    String? backendUrl = prefs.getString('serviceUrl');
    if (backendUrl == null || backendUrl == "") {
      throw SettingException('Missing backendUrl');
    }
    var response = await http.post(Uri.http(backendUrl, '/api/activationsend'),
        headers: {"Access-Control-Allow-Origin": "*"},
        body: {'email': email, 'password': password});
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
      // Await the http get response, then decode the json-formatted response.
      try {
        // Obtain shared preferences.
        final prefs = await SharedPreferences.getInstance();
        String? backendUrl = prefs.getString('serviceUrl');
        if (backendUrl == null || backendUrl == "") {
          throw new MsgException('Missing backendUrl');
        }
        var response = await http.post(Uri.http(backendUrl, '/api/register'),
            headers: {"Access-Control-Allow-Origin": "*"},
            body: {'email': email, 'password': password});
        if (response.statusCode == 200) {
          logIn(email: email, password: password);
        } else {
          print('Request failed with status: ${response.statusCode}.');
        }
      } catch (e) {
        print("Error: " + e.toString());
      }
    } else {
      print("incorrect password confirmation");
    }
  }

  Future<void> forgottenPassword({
    required String email,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.add(AuthenticationStatus.authenticated),
    );
  }

  void dispose() => _controller.close();
}
