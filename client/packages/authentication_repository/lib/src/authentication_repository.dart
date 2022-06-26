import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

const backendUrl = 'localhost:5000';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

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
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.add(AuthenticationStatus.authenticated),
    );
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password == confirmPassword) {
      // Await the http get response, then decode the json-formatted response.
      print("response before");
      try {
        var response = await http.post(Uri.http(backendUrl, '/api/register'),
            headers:{"Access-Control-Allow-Origin": "*"},
            body: {'email': email, 'password': password});
        print("response after");
        print(response.body);
        if (response.statusCode == 200) {
          print(response.body);
          var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
          print(jsonResponse);
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
