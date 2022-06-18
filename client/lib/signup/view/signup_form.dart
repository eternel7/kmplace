import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/signup/signup.dart';
import '/login/login.dart';
import 'package:formz/formz.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(t.authenticationFailure)),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _UsernameInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _PasswordInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _PasswordConfirmInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _SignupButton(),
            const Padding(padding: EdgeInsets.all(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(t.alreadyAnAccount),
                TextButton(
                  child: Text(
                    t.goLoginButton,
                    style: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.push(context, LoginPage.route());
                    //login screen
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return TextField(
          key: const Key('SignupForm_usernameInput_textField'),
          onChanged: (username) =>
              context.read<SignupBloc>().add(SignupUsernameChanged(username)),
          decoration: InputDecoration(
            labelText: t.username,
            errorText: state.username.invalid ? t.invalidUsername : null,
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

    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('SignupForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<SignupBloc>().add(SignupPasswordChanged(password)),
          obscureText: true,
          decoration: InputDecoration(
            labelText: t.password,
            errorText: state.password.invalid
                ? t.passwordRequireUpperAndLowercaseNumAnd8min
                : null,
          ),
        );
      },
    );
  }
}

class _PasswordConfirmInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.confirmPassword != current.confirmPassword,
      builder: (context, state) {
        return TextField(
          key: const Key('SignupForm_confirmPasswordInput_textField'),
          onChanged: (confirmPassword) =>
              context.read<SignupBloc>().add(SignupConfirmPasswordChanged(confirmPassword)),
          obscureText: true,
          decoration: InputDecoration(
            labelText: t.confirmPassword,
            errorText: state.confirmPassword.invalid
                ? t.confirmPasswordInvalid
                : null,
          ),
        );
      },
    );
  }
}

class _SignupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('SignupForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 20)),
                onPressed: state.status.isValidated
                    ? () {
                        context.read<SignupBloc>().add(const SignupSubmitted());
                      }
                    : null,
                child: Text(t.signUpButton),
              );
      },
    );
  }
}
