import 'package:easy_localization/easy_localization.dart';
import 'package:wereward/dark_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:provider/provider.dart';
import 'package:wereward/version.dart';

import 'shared/api_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Intl.defaultLocale = 'th';
  // initializeDateFormatting();

  //16557962-88 SUKSAPAN Online
  //16564548-34 SUKSAPAN Online
  LineSDK.instance.setup('1656454834').then((_) {
    print('LineSDK Prepared');
  });

  // these 2 lines
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //

  // NotificationService.instance.start();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('th')],
      path: 'assets/translations',
      fallbackLocale: Locale('th'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    // set bacground color notificationbar.
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // portrait only.
    _portraitModeOnly();
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: ThemeData(
              // SUKSAPAN-Online
              primaryColor: Color(0xFF2FC4B2),
              accentColor: Color(0xFF2FC4B2),
              backgroundColor: Color(0xFFf7f7f7),
              fontFamily: 'Kanit',
              // We-Mart
              // primaryColor: Color(0xFF1794D2),
              // accentColor: Color(0xFF2A9EB5),
              // backgroundColor: Color(0xFFFFFFFF),
              // fontFamily: 'Kanit',
            ),
            title: appName,
            home: VersionPage(),
            builder: (context, child) {
              return MediaQuery(
                child: child,
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              );
            },
          );
        },
      ),
    );
  }
}

void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
