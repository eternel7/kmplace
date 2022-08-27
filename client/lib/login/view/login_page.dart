import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/login/login.dart';
import '/settings/settings.dart';
import '/widgets/banner/banner.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.loginTitle), automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: InkWell(
              child: const Icon(Icons.settings),
              onTap: () {
                Navigator.push(context, SettingsPage.route());
              },
            ),
          )
        ],),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          const BannerWidget(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: BlocProvider(
                create: (context) {
                  return LoginBloc(
                    authenticationRepository:
                        RepositoryProvider.of<AuthenticationRepository>(context),
                  );
                },
                child: const LoginForm(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
