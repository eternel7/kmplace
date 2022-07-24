import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/forgottenpassword/forgottenpassword.dart';
import '/widgets/passwordfield.dart';
import '/signup/signup.dart';
import '/login/login.dart';
import '/settings/settings.dart';
import 'package:formz/formz.dart';

class ForgottenPasswordForm extends StatelessWidget {
  const ForgottenPasswordForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocListener<ForgottenPasswordBloc, ForgottenPasswordState>(
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
            _EmailInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _ForgottenPasswordAskCode(),
            const Padding(padding: EdgeInsets.all(12)),
            _ActivationInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _PasswordInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _PasswordConfirmInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _ForgottenPasswordButton(),
            const Padding(padding: EdgeInsets.all(12)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(t.alreadyAnAccount),
                  TextButton(
                    child: Text(
                      t.goLoginButton,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.push(context, LoginPage.route());
                      //login screen
                    },
                  )
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(t.noAccountYet),
                  TextButton(
                    child: Text(
                      t.goSignUpButton,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.push(context, SignupPage.route());
                      //signup screen
                    },
                  )
                ])
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ForgottenPasswordBloc, ForgottenPasswordState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('forgottenPasswordForm_emailInput_textField'),
          onChanged: (email) =>
              context.read<ForgottenPasswordBloc>().add(ForgottenPasswordEmailChanged(email)),
          decoration: InputDecoration(
            filled: true,
            labelText: t.email,
            errorText: state.email.invalid ? t.invalidEmail : null,
          ),
        );
      },
    );
  }
}

class _ForgottenPasswordAskCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ForgottenPasswordBloc, ForgottenPasswordState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : Column(children: [
                Text(t.forgottenPasswordSend),
                const Padding(padding: EdgeInsets.all(5)),
                ElevatedButton(
                  key: const Key('forgottenPasswordForm_continue_raisedButton'),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                  onPressed: state.email.invalid || !state.email.value.isNotEmpty
                      ? null
                      : () {
                          context
                              .read<ForgottenPasswordBloc>()
                              .add(const ForgottenPasswordAskCode());
                        },
                  child: Text(t.forgottenPasswordAskCodeButton),
                ),
              ]);
      },
    );
  }
}

class _ActivationInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ForgottenPasswordBloc, ForgottenPasswordState>(
      buildWhen: (previous, current) =>
          previous.forgottenPasswordCode != current.forgottenPasswordCode,
      builder: (context, state) {
        return TextField(
          key: const Key('activationForm_activationCodeInput_textField'),
          onChanged: (activationCode) => context
              .read<ForgottenPasswordBloc>()
              .add(ForgottenPasswordCodeChanged(activationCode)),
          decoration: InputDecoration(
            filled: true,
            labelText: t.forgottenPasswordCode,
            errorText: state.forgottenPasswordCode.invalid ? t.forgottenPasswordCodeRequired : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ForgottenPasswordBloc, ForgottenPasswordState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return PasswordField(
          fieldKey: const Key('SignupForm_passwordInput_textField'),
          onChanged: (password) => context.read<ForgottenPasswordBloc>().add(ForgottenPasswordPasswordChanged(password!)),
          labelText: t.password,
          helperText: t.passwordRequireUpperAndLowercaseNumAnd8min,
          errorText: state.password.invalid ? t.passwordRequireUpperAndLowercaseNumAnd8min : null,
        );
      },
    );
  }
}

class _PasswordConfirmInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ForgottenPasswordBloc, ForgottenPasswordState>(
      buildWhen: (previous, current) => (previous.confirmPassword != current.confirmPassword ||
          previous.password != current.password),
      builder: (context, state) {
        return PasswordField(
          fieldKey: const Key('SignupForm_confirmPasswordInput_textField'),
          onChanged: (confirmPassword) =>
              context.read<ForgottenPasswordBloc>().add(ForgottenPasswordConfirmPasswordChanged(confirmPassword!)),
          labelText: t.confirmPassword,
          helperText: "",
          errorText: state.confirmPassword.invalid ? t.confirmPasswordInvalid : null,
        );
      },
    );
  }
}

class _ForgottenPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ForgottenPasswordBloc, ForgottenPasswordState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('forgottenPasswordForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                onPressed: state.status.isValidated
                    ? () {
                        context
                            .read<ForgottenPasswordBloc>()
                            .add(const ForgottenPasswordSubmitted());
                      }
                    : null,
                child: Text(t.forgottenPasswordSaveButton),
              );
      },
    );
  }
}
