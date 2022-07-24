import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/activation/activation.dart';
import '/signup/signup.dart';
import '/settings/settings.dart';
import 'package:formz/formz.dart';

class ActivationForm extends StatelessWidget {
  const ActivationForm({Key? key, required this.information}) : super(key: key);

  final Map<String, dynamic> information;

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocListener<ActivationBloc, ActivationState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          if (state.type == "setting") {
            Navigator.push(context, SettingsPage.route());
          } else if (state.type == "activation") {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(t.activationCodeIncorrect)),
              );
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
        } else if (state.status.isSubmissionSuccess && state.type == "send") {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content: Text(
                t.activationCodeSendAgain,
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
            Text(
              information['email']!,
              style: const TextStyle(fontSize: 20),
            ),
            const Padding(padding: EdgeInsets.all(12)),
            _ActivationInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _ActivateButton(email: information['email']!, password: information['password']!),
            const Padding(padding: EdgeInsets.all(12)),
            _ActivateSendButton(email: information['email']!, password: information['password']!),
            const Padding(padding: EdgeInsets.all(12)),
            Text(t.noAccountYet),
            TextButton(
              child: Text(
                t.goSignUpButton,
                style: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(context, SignupPage.route());
                //signup screen
              },
            )
          ],
        ),
      ),
    );
  }
}

class _ActivationInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ActivationBloc, ActivationState>(
      buildWhen: (previous, current) => previous.activationCode != current.activationCode,
      builder: (context, state) {
        return TextField(
          key: const Key('activationForm_activationCodeInput_textField'),
          onChanged: (activationCode) =>
              context.read<ActivationBloc>().add(ActivationCodeChanged(activationCode)),
          decoration: InputDecoration(
            filled: true,
            labelText: t.activationCode,
            errorText: state.activationCode.invalid ? t.activationCodeRequired : null,
          ),
        );
      },
    );
  }
}

class _ActivateButton extends StatelessWidget {
  const _ActivateButton({Key? key, required this.email, required this.password}) : super(key: key);
  final String email;
  final String password;

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ActivationBloc, ActivationState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('activationForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                onPressed: state.status.isValidated
                    ? () {
                        context.read<ActivationBloc>().add(ActivationSubmitted(email, password));
                      }
                    : null,
                child: Text(t.activationValidateButton),
              );
      },
    );
  }
}

class _ActivateSendButton extends StatelessWidget {
  const _ActivateSendButton({Key? key, required this.email, required this.password}) : super(key: key);
  final String email;
  final String password;

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ActivationBloc, ActivationState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('activationForm_send_raisedButton'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                onPressed: () {
                  context.read<ActivationBloc>().add(ActivationSend(email, password));
                },
                child: Text(t.activationSendButton),
              );
      },
    );
  }
}
