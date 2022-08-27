import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_repository/user_repository.dart';
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
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool circular = false;

  TextEditingController tecUsername = TextEditingController();
  TextEditingController tecFullname = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      tecUsername.text = widget.user.username;
      tecFullname.text = widget.user.fullname;
    });
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
            imageProfile(),
            const Padding(padding: EdgeInsets.all(12)),
            Text(
              widget.user.username.isEmpty ? widget.user.email : widget.user.username,
              style: const TextStyle(fontSize: 20),
            ),
            const Padding(padding: EdgeInsets.all(12)),
            TextFieldFormInput(
              controller: tecUsername,
              buildWhen: (previous, current) => previous.username != current.username,
              textFieldKey: const Key('accountForm_usernameInput_textField'),
              onChanged: (v) => context.read<AccountBloc>().add(AccountUsernameChanged(v)),
              labelText: t.accountUsername,
            ),
            const Padding(padding: EdgeInsets.all(12)),
            TextFieldFormInput(
              controller: tecFullname,
              buildWhen: (previous, current) => previous.fullname != current.fullname,
              textFieldKey: const Key('accountForm_fullnameInput_textField'),
              onChanged: (v) => context.read<AccountBloc>().add(AccountFullnameChanged(v)),
              labelText: t.accountFullname,
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

  String initials(String fullname, String email) {
    if (fullname.isEmpty) {
      return email.substring(0, 2).toUpperCase();
    } else {
      List nm = fullname.split(" ");
      if (nm.length >= 2) {
        return nm[0].substring(0, 1).toUpperCase() + nm[1].substring(0, 1).toUpperCase();
      }
      return fullname.substring(0, 2).toUpperCase();
    }
  }

  Widget imageProfile() {
    double circleSize = 40.0;
    return Center(
      child: Stack(children: <Widget>[
        widget.user.image.isEmpty
            ? CircleAvatar(
                radius: circleSize,
                child: Text(initials(widget.user.fullname, widget.user.email),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: circleSize / 1.7,
                      fontWeight: FontWeight.bold,
                    )))
            : CircleAvatar(
                radius: circleSize,
                backgroundImage: _imageFile == null
                    ? NetworkImage(widget.user.image)
                    : FileImage(File(_imageFile!.path)) as ImageProvider,
              ),
        Positioned(
          bottom: circleSize / 4,
          right: circleSize / 4,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: Icon(
              Icons.camera_alt,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: circleSize / 2.2,
            ),
          ),
        ),
      ]),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.camera),
              onPressed: () {
                takePhoto(ImageSource.camera);
              },
              label: const Text("Camera"),
            ),
            TextButton.icon(
              icon: const Icon(Icons.image),
              onPressed: () {
                takePhoto(ImageSource.gallery);
              },
              label: const Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
    );
    setState(() {
      _imageFile = pickedFile;
    });
  }
}

class TextFieldFormInput extends StatelessWidget {
  const TextFieldFormInput(
      {Key? key,
      required this.controller,
      required this.buildWhen,
      required this.textFieldKey,
      required this.onChanged,
      required this.labelText})
      : super(key: key);
  final TextEditingController controller;
  final Function buildWhen;
  final Key textFieldKey;
  final Function onChanged;
  final String labelText;

  @override
  Widget build(BuildContext context) {
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
