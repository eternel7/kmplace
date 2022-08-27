import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import '/authentication/bloc/authentication_bloc.dart';
import '/account/account.dart';
import '/settings/settings.dart';
import 'package:formz/formz.dart';

class AccountForm extends StatelessWidget {
  const AccountForm({Key? key, required this.user}) : super(key: key);

  final User user;

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
            user.image.isEmpty
                ? CircleAvatar(child: Text(user.email.substring(0, 2).toUpperCase()))
                : CircleAvatar(
                    backgroundImage: NetworkImage(user.image),
                  ),
            const Padding(padding: EdgeInsets.all(12)),
            Text(
              user.username.isEmpty ?  user.email : user.username,
              style: const TextStyle(fontSize: 20),
            ),
            const Padding(padding: EdgeInsets.all(12)),
            TextFieldFormInput(
              label: user.username,
              buildWhen: (previous, current) => previous.username != current.username,
              textFieldKey: const Key('accountForm_usernameInput_textField'),
              onChanged: (v) => context.read<AccountBloc>().add(AccountUsernameChanged(v)),
              labelText: t.accountUsername,
            ),
            const Padding(padding: EdgeInsets.all(12)),
            TextFieldFormInput(
              label: user.fullname,
              buildWhen: (previous, current) => previous.fullname != current.fullname,
              textFieldKey: const Key('accountForm_fullnameInput_textField'),
              onChanged: (v) => context.read<AccountBloc>().add(AccountFullnameChanged(v)),
              labelText: t.accountFullname,
            ),
            const Padding(padding: EdgeInsets.all(12)),
            TextFieldFormInput(
              label: user.image,
              buildWhen: (previous, current) => previous.image != current.image,
              textFieldKey: const Key('accountForm_imageInput_textField'),
              onChanged: (v) => context.read<AccountBloc>().add(AccountImageChanged(v)),
              labelText: t.accountImage,
            ),
            const Padding(padding: EdgeInsets.all(12)),
            AccountActionButton(
                user: user,
                buttonKey: const Key('accountForm_update'),
                onPressed: (user) {
                  context.read<AccountBloc>().add(AccountSubmitted(user));
                },
                buttonLabel: t.accountUpdateButton),
            const Padding(padding: EdgeInsets.all(12)),
            AccountActionButton(
                user: user,
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

class TextFieldFormInput extends StatelessWidget {
  const TextFieldFormInput(
      {Key? key,
      required this.label,
      required this.buildWhen,
      required this.textFieldKey,
      required this.onChanged,
      required this.labelText})
      : super(key: key);
  final String label;
  final Function buildWhen;
  final Key textFieldKey;
  final Function onChanged;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: label);
    return BlocBuilder<AccountBloc, AccountState>(
        buildWhen: (previous, current) => buildWhen(previous, current),
        builder: (context, state) {
          return TextField(
            key: textFieldKey,
            controller: controller,
            onChanged: (val) => onChanged(val),
            decoration: InputDecoration(filled: true, labelText: labelText),
          );
        });
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
