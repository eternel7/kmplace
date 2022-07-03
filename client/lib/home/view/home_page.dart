import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '/authentication/authentication.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.homeTitle), automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Builder(
              builder: (context) {
                final user = context.select(
                  (AuthenticationBloc bloc) => bloc.state.user,
                );
                return Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Text(t.userEmailProfile + user.email),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Text(t.userLoginCount + user.login_counts.toString()),
                    ),
                  ),
                  const SizedBox(width: 50, height: 50),
                ]);
              },
            ),
            ElevatedButton(
              child: Text(t.logout),
              onPressed: () {
                context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}
