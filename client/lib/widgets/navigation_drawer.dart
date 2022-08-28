import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '/widgets/profile_networkimage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/authentication/authentication.dart';
import '/home/home.dart';
import '/account/account.dart';

class PageListTile extends StatelessWidget {
  const PageListTile({
    Key? key,
    this.selectedPageId,
    required this.pageId,
    required this.pageLabel,
    required this.pageIcon,
    required this.onPressed,
  }) : super(key: key);
  final String? selectedPageId;
  final String pageId;
  final String pageLabel;
  final Icon pageIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        // show a check icon if the page is currently selected
        // note: we use Opacity to ensure that all tiles have a leading widget
        // and all the titles are left-aligned
        selected: selectedPageId == pageId,
        leading: pageIcon,
        title: Text(pageLabel),
        onTap: () {
          Navigator.pop(context);
          onPressed!();
        });
  }
}

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key, required this.selectedPageId}) : super(key: key);

  final String selectedPageId;

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  late SharedPreferences prefs;
  String _serviceUrl = "";
  String token = "";

  void loadServiceURL() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _serviceUrl = (prefs.getString('serviceUrl') ?? "");
      token = (prefs.getString('token') ?? "");
    });
  }

  @override
  void initState() {
    super.initState();
    loadServiceURL();
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);
    return Builder(builder: (context) {
      final user = context.select(
        (AuthenticationBloc bloc) => bloc.state.user,
      );

      return Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.fullname.isEmpty ? user.username : user.fullname),
              accountEmail: Text(user.email),
              currentAccountPicture: (user.image.isEmpty || _serviceUrl.isEmpty || token.isEmpty)
                  ? CircleAvatar(
                      minRadius: 50, child: Text(user.email.substring(0, 2).toUpperCase()))
                  : CircleAvatar(
                      minRadius: 50,
                      backgroundImage: profileNetworkImage(_serviceUrl, token, user.email)),
            ),
            PageListTile(
                selectedPageId: widget.selectedPageId,
                pageId: "",
                pageLabel: 'Home',
                pageIcon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.push(context, HomePage.route());
                }),
            const Divider(),
            PageListTile(
                selectedPageId: widget.selectedPageId,
                pageId: "account",
                pageLabel: t.account,
                pageIcon: const Icon(Icons.account_box),
                onPressed: () {
                  Navigator.push(context, AccountPage.route());
                }),
            PageListTile(
                pageId: "logout",
                pageLabel: t.logout,
                pageIcon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
                }),
            AboutListTile(
              icon: const Icon(
                Icons.info,
              ),
              applicationIcon: Image.asset('asset/images/logo_home.png', height: 50, width: 50),
              applicationName: 'KMPlace',
              applicationVersion: '1.0.0',
              applicationLegalese: '\u{a9} 2022 Unicorn',
              aboutBoxChildren: const [
                ///Content goes here...
              ],
              child: Text(t.aboutApp),
            ),
          ],
        ),
      );
    });
  }
}
