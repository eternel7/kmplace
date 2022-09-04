import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';
import '/widgets/textfield_input.dart';
import '/widgets/image_profile.dart';
import '/authentication/bloc/authentication_bloc.dart';
import '/account/account.dart';
import '/settings/settings.dart';
import 'package:formz/formz.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  late SharedPreferences _prefs;

  void loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          if (state.type == "setting") {
            Navigator.push(context, SettingsPage.route());
          } else if (state.type == "unknown" || state.type == "authentication") {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                  ),
                )),
              );
          }
        } else if (state.status.isSubmissionSuccess && state.type == "done") {
          context.read<AuthenticationBloc>().add(AuthenticationUserChanged());
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content: Text(
                t.updateDone,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.green,
                ),
              )),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ProfileWidget(
                user: widget.user,
                isEdit: true,
                onUpdate: (response) {
                  var jsonResponse = convert.jsonDecode(response) as Map<String, dynamic>;
                  if (jsonResponse['status'] == true) {
                    // Update user
                    _prefs.setString('login_response', response);
                    context.read<AuthenticationBloc>().add(AuthenticationUserChanged());
                  } else {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                            content: Text(
                          jsonResponse['message'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                          ),
                        )),
                      );
                  }
                }),
            const Padding(padding: EdgeInsets.all(12)),
            Text(
              widget.user.fullname.isEmpty ? widget.user.email : widget.user.fullname,
              style: const TextStyle(fontSize: 20),
            ),
            const Padding(padding: EdgeInsets.all(12)),
            TextFieldFormInput(
              text: widget.user.username,
              labelText: t.accountUsername,
              textFieldKey: const Key('accountForm_usernameInput_textField'),
              onChanged: (v) => context.read<AccountBloc>().add(AccountUsernameChanged(v)),
            ),
            const Padding(padding: EdgeInsets.all(12)),
            TextFieldFormInput(
              labelText: t.accountFullname,
              text: widget.user.fullname,
              textFieldKey: const Key('accountForm_fullnameInput_textField'),
              onChanged: (v) => context.read<AccountBloc>().add(AccountFullnameChanged(v)),
            ),
            const Padding(padding: EdgeInsets.all(12)),
            AccountActionButton(
                user: widget.user,
                buttonKey: const Key('accountForm_update'),
                onPressed: (user) {
                  context.read<AccountBloc>().add(AccountSubmitted(user));
                },
                buttonLabel: t.accountUpdateButton),
            const Padding(padding: EdgeInsets.all(12)),
            AccountActionButton(
                user: widget.user,
                buttonKey: const Key('accountForm_delete'),
                onPressed: (user) {
                  context.read<AccountBloc>().add(AccountDelete(user));
                },
                buttonLabel: t.accountDeleteButton),
          ],
        ),
      ),
    );
  }
}

class AccountActionButton extends StatelessWidget {
  const AccountActionButton(
      {Key? key,
      required this.user,
      required this.buttonKey,
      required this.onPressed,
      required this.buttonLabel})
      : super(key: key);
  final User user;
  final Key buttonKey;
  final Function onPressed;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: buttonKey,
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                onPressed: state.status.isValidated
                    ? () {
                        onPressed(user);
                      }
                    : null,
                child: Text(buttonLabel),
              );
      },
    );
  }
}
