import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/forgottenpassword/forgottenpassword.dart';
import '/signup/signup.dart';
import 'package:formz/formz.dart';
import 'package:kmplace/constants.dart';

class ForgottenPasswordForm extends StatelessWidget {
  const ForgottenPasswordForm({Key? key}) : super(key: key);

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
    return BlocListener<ForgottenPasswordBloc, ForgottenPasswordState>(
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
            _ForgottenPasswordButton(),
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

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return BlocBuilder<ForgottenPasswordBloc, ForgottenPasswordState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('forgottenPasswordForm_usernameInput_textField'),
          onChanged: (email) =>
              context.read<ForgottenPasswordBloc>().add(ForgottenPasswordUsernameChanged(email)),
          decoration: InputDecoration(
            filled: true,
            labelText: t.username,
            errorText: state.email.invalid ? t.invalidUsername : null,
          ),
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
                child: Text(t.forgottenPasswordButton),
              );
      },
    );
  }
}
