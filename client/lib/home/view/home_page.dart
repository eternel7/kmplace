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
    return const HomePageView();
  }
}

class HomePageView extends StatefulWidget {
  const HomePageView({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePageView> {
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
                  child: Text(t.userLoginCount + user.login_counts.toString()),
                ),
              ),
            ])
          ],
        )),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("${user.fullname} ${user.username}"),
                accountEmail: Text(user.email),
                currentAccountPicture: user.image.isEmpty
                    ? CircleAvatar(child: Text(user.email.substring(0, 2).toUpperCase()))
                    : CircleAvatar(
                        backgroundImage: NetworkImage(user
                            .image), //"https://cdn.myanimelist.net/r/360x360/images/characters/9/310307.jpg?s=56335bffa6f5da78c3824ba0dae14a26"),
                      ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_box),
                title: Text(t.account),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(t.logout),
                onTap: () {
                  context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      );
    });
  }
}
