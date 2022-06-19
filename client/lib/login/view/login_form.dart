import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/widgets/passwordfield.dart';
import '/login/login.dart';
import '/signup/signup.dart';
import '/forgottenpassword/forgottenpassword.dart';
import 'package:formz/formz.dart';
import 'package:kmplace/constants.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);
    bool isScreenWide = MediaQuery.of(context).size.width >= kMinWidthOfLargeScreen;
    List<Widget> footer = [
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
    ];
    return BlocListener<LoginBloc, LoginState>(
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
            _LoginButton(),
            const Padding(padding: EdgeInsets.all(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  child: Text(
                    t.forgottenPassword,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onPressed: () {
                    Navigator.push(context, ForgottenPasswordPage.route());
                    //forgotten password screen
                  },
                )
              ],
            ),
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
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_usernameInput_textField'),
          onChanged: (username) => context.read<LoginBloc>().add(LoginUsernameChanged(username)),
          decoration: InputDecoration(
            filled: true,
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

    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return PasswordField(
          fieldKey: const Key('loginForm_passwordInput_textField'),
          onChanged: (password) => context.read<LoginBloc>().add(LoginPasswordChanged(password!)),
          labelText: t.password,
          helperText: t.passwordRequireUpperAndLowercaseNumAnd8min,
          errorText: state.password.invalid ? t.passwordRequireUpperAndLowercaseNumAnd8min : null,
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('loginForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                onPressed: state.status.isValidated
                    ? () {
                        context.read<LoginBloc>().add(const LoginSubmitted());
                      }
                    : null,
                child: Text(t.loginButton),
              );
      },
    );
  }
}
