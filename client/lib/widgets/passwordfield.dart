import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final List<IconData> iconData = <IconData>[
  Icons.ac_unit,
  Icons.account_balance_wallet,
  Icons.account_box,
  Icons.account_circle,
  Icons.adb,
  Icons.add_box,
  Icons.add_circle,
  Icons.adjust_rounded,
  Icons.air,
  Icons.airline_stops,
  Icons.airlines,
  Icons.album,
  Icons.align_horizontal_center,
  Icons.align_horizontal_left,
  Icons.align_horizontal_right,
  Icons.align_vertical_bottom,
  Icons.align_vertical_center,
  Icons.align_vertical_top,
  Icons.all_inclusive,
  Icons.all_out_rounded,
  Icons.analytics,
  Icons.anchor,
  Icons.animation,
  Icons.api,
  Icons.app_registration,
  Icons.app_shortcut,
  Icons.approval,
  Icons.apps,
  Icons.area_chart,
  Icons.assessment,
  Icons.assignment_ind,
  Icons.assignment_turned_in,
  Icons.assistant,
  Icons.assistant_photo,
  Icons.attractions,
  Icons.attribution,
  Icons.audiotrack,
  Icons.auto_awesome,
  Icons.auto_awesome_mosaic,
  Icons.auto_awesome_outlined,
  Icons.auto_fix_high_outlined,
  Icons.auto_graph,
  Icons.auto_stories,
  Icons.badge,
  Icons.bakery_dining_outlined,
  Icons.bakery_dining_rounded,
  Icons.balcony,
  Icons.bar_chart_rounded,
  Icons.batch_prediction,
  Icons.beach_access,
  Icons.beenhere,
  Icons.beenhere_outlined,
  Icons.bolt,
  Icons.book,
  Icons.book_outlined,
  Icons.bookmark,
  Icons.bookmark_outline,
  Icons.brightness_5,
  Icons.brightness_7,
  Icons.brush,
  Icons.bubble_chart,
  Icons.build,
  Icons.cake,
  Icons.cake_outlined,
  Icons.candlestick_chart,
  Icons.candlestick_chart_outlined,
  Icons.card_giftcard,
  Icons.card_membership,
  Icons.casino,
  Icons.casino_outlined,
  Icons.castle,
  Icons.castle_outlined,
  Icons.catching_pokemon,
  Icons.category,
  Icons.category_outlined,
  Icons.celebration,
  Icons.change_history,
  Icons.check_box_rounded,
  Icons.check_circle_outline,
  Icons.checkroom,
  Icons.church,
  Icons.child_care,
  Icons.cloud,
  Icons.cloud_done_outlined,
  Icons.coffee,
  Icons.coffee_maker,
  Icons.coffee_outlined,
  Icons.commit,
  Icons.computer,
  Icons.confirmation_num,
  Icons.confirmation_num_outlined,
  Icons.connecting_airports,
  Icons.construction,
  Icons.contact_page,
  Icons.contacts,
  Icons.cookie,
  Icons.cookie_outlined,
  Icons.cruelty_free,
  Icons.cruelty_free_outlined,
  Icons.deck,
  Icons.design_services,
  Icons.design_services_outlined,
  Icons.favorite,
  Icons.grade,
  Icons.mosque,
  Icons.mood,
  Icons.star,
];

class PasswordField extends StatefulWidget {
  const PasswordField(
      {Key? key,
      required this.fieldKey,
      required this.labelText,
      required this.helperText,
      required this.errorText,
      required this.onChanged})
      : super(key: key);

  final Key fieldKey;
  final String labelText;
  final String helperText;
  final String? errorText;
  final FormFieldSetter<String> onChanged;

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);
    final String hash = passwordController.text.isNotEmpty
        ? md5.convert(utf8.encode(passwordController.text)).toString()
        : "";
    int hashNumIcon = 0;
    int hashNumColor = 7;
    for (var c in hash.runes) {
      hashNumIcon += c.hashCode;
      hashNumColor += c.hashCode - 1;
    }

    return TextFormField(
      key: widget.fieldKey,
      obscureText: _obscureText,
      controller: passwordController,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        filled: true,
        labelText: widget.labelText,
        helperText: widget.helperText,
        helperMaxLines: 2,
        errorText: widget.errorText,
        errorMaxLines: 2,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // added line
            mainAxisSize: MainAxisSize.min, // added line
            children: <Widget>[
              passwordController.text.isNotEmpty && passwordController.text.length > 4
                  ? Tooltip(
                      message: t.passwordInputVisualHelp,
                      child: Icon(iconData[hashNumIcon % iconData.length],
                          color: Colors.primaries[hashNumColor % Colors.primaries.length]),
                    )
                  : const SizedBox(width: 24.0),
              Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              const SizedBox(width: 5.0)
            ],
          ),
        ),
      ),
    );
  }
}
