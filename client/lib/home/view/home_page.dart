import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '/authentication/authentication.dart';
import '/widgets/navigation_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);
    return Builder(builder: (context) {
      final user = context.select(
        (AuthenticationBloc bloc) => bloc.state.user,
      );
      return Scaffold(
        appBar: AppBar(title: Text(t.homeTitle)),
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Center(
                  child: Text(t.userEmailProfile + user.email),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Center(
                  child: Text(user.username),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Center(
                  child: Text(user.fullname),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Center(
                  child: Text(t.userLoginCount + user.login_counts.toString()),
                ),
              ),
            ])
          ],
        )),
        drawer: const NavigationDrawer(selectedPageId : ""),
      );
    });
  }
}
