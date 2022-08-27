import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/forgottenpassword/forgottenpassword.dart';
import '/widgets/banner/banner.dart';

class ForgottenPasswordPage extends StatelessWidget {
  const ForgottenPasswordPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const ForgottenPasswordPage());
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.forgottenPasswordTitle)),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          const BannerWidget(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: BlocProvider(
                create: (context) {
                  return ForgottenPasswordBloc(
                    authenticationRepository:
                        RepositoryProvider.of<AuthenticationRepository>(context),
                  );
                },
                child: const ForgottenPasswordForm(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
