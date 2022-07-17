import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/activation/activation.dart';
import '/banner/banner.dart';

class ActivationPage extends StatelessWidget {
  const ActivationPage({Key? key, required this.information}) : super(key: key);

  final Map<String, dynamic> information;

  static Route route(info) {
    return MaterialPageRoute<void>(builder: (_) => ActivationPage(information: info));
  }

  @override
  Widget build(BuildContext context) {
    final t = I10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          const BannerWidget(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: BlocProvider(
                create: (context) {
                  return ActivationBloc(
                    authenticationRepository:
                        RepositoryProvider.of<AuthenticationRepository>(context),
                  );
                },
                child: ActivationForm(information: information),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
