import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/authentication/authentication.dart';
import '/account/account.dart';
import '/widgets/navigation_drawer.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const AccountPage());
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);
    return Builder(builder: (context) {
      final user = context.select(
        (AuthenticationBloc bloc) => bloc.state.user,
      );
      return Scaffold(
        appBar: AppBar(title: Text(t.accountTitle)),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: BlocProvider(
                create: (context) {
                  return AccountBloc(
                    authenticationRepository:
                        RepositoryProvider.of<AuthenticationRepository>(context),
                  );
                },
                child: AccountForm(user: user),
              ),
            ),
          ]),
        ),
        drawer: const NavigationDrawer(selectedPageId: "account"),
      );
    });
  }
}
