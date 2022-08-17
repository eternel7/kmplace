import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import '/account/account.dart';
import '/settings/settings.dart';
import 'package:formz/formz.dart';

class AccountForm extends StatelessWidget {
  const AccountForm({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          if (state.type == "setting") {
            Navigator.push(context, SettingsPage.route());
          } else if (state.type == "msg" || state.type == "service") {
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
              user.email,
              style: const TextStyle(fontSize: 20),
            ),
            const Padding(padding: EdgeInsets.all(12)),
            _UserNameInput(label: user.username),
            const Padding(padding: EdgeInsets.all(12)),
            _FullnameInput(label: user.fullname),
            const Padding(padding: EdgeInsets.all(12)),
            _ImageInput(label: user.image),
            const Padding(padding: EdgeInsets.all(12)),
            _UpdateButton(user: user),
            const Padding(padding: EdgeInsets.all(12)),
            _DeleteButton(user: user),
          ],
        ),
      ),
    );
  }
}

class _UserNameInput extends StatelessWidget {
  const _UserNameInput({Key? key, required this.label}) : super(key: key);
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return TextField(
      key: const Key('accountForm_usernameInput_textField'),
      controller: TextEditingController(text: label),
      decoration: InputDecoration(filled: true, labelText: t.accountUsername),
    );
  }
}

class _FullnameInput extends StatelessWidget {
  const _FullnameInput({Key? key, required this.label}) : super(key: key);
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return TextField(
      key: const Key('accountForm_fullNameInput_textField'),
      controller: TextEditingController(text: label),
      decoration: InputDecoration(filled: true, labelText: t.accountFullname),
    );
  }
}

class _ImageInput extends StatelessWidget {
  const _ImageInput({Key? key, required this.label}) : super(key: key);
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return TextField(
      key: const Key('accountForm_imageInput_textField'),
      controller: TextEditingController(text: label),
      decoration: InputDecoration(filled: true, labelText: t.accountImage),
    );
  }
}

class _UpdateButton extends StatelessWidget {
  const _UpdateButton({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('accountForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                onPressed: state.status.isValidated
                    ? () {
                        context.read<AccountBloc>().add(AccountSubmitted(user));
                      }
                    : null,
                child: Text(t.accountUpdateButton),
              );
      },
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('accountForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                onPressed: state.status.isValidated
                    ? () {
                        context.read<AccountBloc>().add(AccountDelete(user));
                      }
                    : null,
                child: Text(t.accountDeleteButton),
              );
      },
    );
  }
}
