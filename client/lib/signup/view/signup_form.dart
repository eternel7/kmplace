import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/widgets/passwordfield.dart';
import '/signup/signup.dart';
import '/login/login.dart';
import 'package:formz/formz.dart';
import 'package:kmplace/constants.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);
    bool isScreenWide = MediaQuery.of(context).size.width >= kMinWidthOfLargeScreen;
    List<Widget> footer = [
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
    ];

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
            _EmailInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _PasswordInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _PasswordConfirmInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _SignupButton(),
            const Padding(padding: EdgeInsets.all(12)),
            isScreenWide
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: footer)
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: footer),
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

    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('SignupForm_emailInput_textField'),
          onChanged: (email) => context.read<SignupBloc>().add(SignupEmailChanged(email)),
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

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return PasswordField(
          fieldKey: const Key('SignupForm_passwordInput_textField'),
          onChanged: (password) => context.read<SignupBloc>().add(SignupPasswordChanged(password!)),
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

    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => (previous.confirmPassword != current.confirmPassword ||
          previous.password != current.password),
      builder: (context, state) {
        return PasswordField(
          fieldKey: const Key('SignupForm_confirmPasswordInput_textField'),
          onChanged: (confirmPassword) =>
              context.read<SignupBloc>().add(SignupConfirmPasswordChanged(confirmPassword!)),
          labelText: t.confirmPassword,
          helperText: "",
          errorText: state.confirmPassword.invalid ? t.confirmPasswordInvalid : null,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
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
