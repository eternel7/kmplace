import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/authentication/authentication.dart';
import '/home/home.dart';
import '/login/login.dart';
import '/settings/settings.dart';
import '/splash/splash.dart';
import 'package:user_repository/user_repository.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.authenticationRepository,
    required this.userRepository,
  }) : super(key: key);

  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
          userRepository: userRepository,
        ),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  AppViewState createState() => AppViewState();
}

class AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  String _serviceUrl = "";
  NavigatorState get _navigator => _navigatorKey.currentState!;
  late SharedPreferences prefs;

  void loadServiceURL() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _serviceUrl = (prefs.getString('serviceUrl') ?? "");
    });
  }
  @override
  void initState() {
    super.initState();
    loadServiceURL();
  }

  TextTheme allTextTheme = TextTheme(
    headline1:
    GoogleFonts.trainOne(fontSize: 116, fontWeight: FontWeight.w300, letterSpacing: -1.5),
    headline2:
    GoogleFonts.trainOne(fontSize: 72, fontWeight: FontWeight.w300, letterSpacing: -0.5),
    headline3: GoogleFonts.trainOne(fontSize: 58, fontWeight: FontWeight.w400),
    headline4:
    GoogleFonts.trainOne(fontSize: 41, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    headline5: GoogleFonts.roboto(fontSize: 29, fontWeight: FontWeight.w400),
    headline6:
    GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    subtitle1:
    GoogleFonts.lora(fontSize: 19, fontWeight: FontWeight.w400, letterSpacing: 0.15),
    subtitle2:
    GoogleFonts.lora(fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyText1:
    GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyText2:
    GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    button:
    GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
    caption:
    GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    overline:
    GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
  );
  @override
  Widget build(BuildContext context) {
    loadServiceURL(); //include to not redirect to setting if update since init
    return MaterialApp(
      localizationsDelegates: const [
        I10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        // 'en' is the language code. We could optionally provide a
        // a country code as the second param, e.g.
        // Locale('en', 'US'). If we do that, we may want to
        // provide an additional app_en_US.arb file for
        // region-specific translations.
        Locale('en', ''),
        Locale('fr', ''),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F0FF),
        colorSchemeSeed: const Color(0xFF01499D), //Colors.indigo,
        // Define the default font family.
        textTheme: allTextTheme,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF01499D),
        brightness: Brightness.dark,
        textTheme: allTextTheme,
      ),
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  HomePage.route(),
                  (route) => false,
                );
                break;
              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                    (_serviceUrl!="") ? LoginPage.route() : SettingsPage.route(),
                  (route) => false,
                );
                break;
              default:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}
