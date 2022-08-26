import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/signup/signup.dart';
import '/login/login.dart';
import 'package:kmplace/constants.dart';

class SettingsForm extends StatelessWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SettingsFormView();
  }
}

class SettingsFormView extends StatefulWidget {
  const SettingsFormView({Key? key}) : super(key: key);

  @override
  SettingsFormViewState createState() => SettingsFormViewState();
}

class SettingsFormViewState extends State<SettingsFormView> {
  String _serviceUrl = "";
  bool _notEmpty = false;
  TextEditingController controller = TextEditingController();
  late SharedPreferences prefs;

  void loadServiceURL() async {
    prefs = await SharedPreferences.getInstance();
    String val = (prefs.getString('serviceUrl') ?? "");
    setState(() {
      _serviceUrl = val;
      controller.text = val;
    });
  }

  void savePreferences() async {
    String val = controller.text.toString();
    prefs = await SharedPreferences.getInstance();
    prefs.setString('serviceUrl', val);
    setState(() {
      _serviceUrl = val;
      controller.text = val;

      final t = I10n.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t.savedone),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: t.goLoginButton,
          textColor: Colors.white,
          onPressed: () => Navigator.push(context, LoginPage.route()),
        ),
      ));
    });
  }

  void deletePreferences() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('serviceUrl');
    setState(() {
      _serviceUrl = "";
      controller.text = "";
    });
  }

  @override
  void initState() {
    super.initState();
    loadServiceURL();
    controller.addListener(() {
      setState(() {
        _notEmpty = controller.text.isNotEmpty && _serviceUrl.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);
    bool isScreenWide = MediaQuery.of(context).size.width >= kMinWidthOfLargeScreen;
    List<Widget> footer = [
      TextButton(
        onPressed: (_notEmpty) ? () => Navigator.push(context, LoginPage.route()) : null,
        child: Text(
          t.goLoginButton,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      const Text(" - "),
      TextButton(
        onPressed: (_notEmpty) ? () => Navigator.push(context, SignupPage.route()) : null,
        child: Text(
          t.goSignUpButton,
          style: const TextStyle(fontSize: 14),
        ),
      )
    ];

    return Align(
      alignment: const Alignment(0, -1 / 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            key: const Key('settingsForm_ServiceInput_textField'),
            controller: controller,
            decoration: InputDecoration(filled: true, labelText: t.serviceUrl),
          ),
          const Padding(padding: EdgeInsets.all(12)),
          Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ElevatedButton(
              key: const Key('settingsForm_save_raisedButton'),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
              onPressed: () {
                savePreferences();
              },
              child: Text(t.settingsSaveButton),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            const Text("-"),
            TextButton(
              key: const Key('settingsForm_delete_raisedButton'),
              onPressed: (_notEmpty) ? () => deletePreferences() : null,
              child: Text(t.settingsDeleteButton, style: const TextStyle(fontSize: 14)),
            ),
          ]),
          const Padding(padding: EdgeInsets.all(12)),
          isScreenWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: footer,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: footer,
                ),
        ],
      ),
    );
  }
}
