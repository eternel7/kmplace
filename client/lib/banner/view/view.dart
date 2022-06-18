import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Center(
          child: SizedBox(width: 100, height: 50, child: Image.asset('asset/images/logo_home.png')),
        ),
      ),
      Center(
        child: Text(
          t.homeTitle,
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
      Center(
        child: Text(
          t.slogan,
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
    ]);
  }
}
