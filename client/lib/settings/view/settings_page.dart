import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '/settings/settings.dart';
import '/banner/banner.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SettingsPage());
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        child: Column(children: const <Widget>[
          BannerWidget(),
          Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: SettingsForm(),
            ),
          ),
        ]),
      ),
    );
  }
}
