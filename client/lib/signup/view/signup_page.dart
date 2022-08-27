import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/signup/signup.dart';
import '/widgets/banner/banner.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SignupPage());
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.signUpTitle)),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          const BannerWidget(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: BlocProvider(
                create: (context) {
                  return SignupBloc(
                    authenticationRepository:
                        RepositoryProvider.of<AuthenticationRepository>(
                            context),
                  );
                },
                child: const SignupForm(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
