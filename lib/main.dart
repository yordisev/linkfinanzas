import 'package:codigoqr/menu.dart';
import 'package:codigoqr/screen/acercade.dart';
import 'package:codigoqr/screen/claves.dart';
import 'package:codigoqr/screen/mislinks.dart';
import 'package:codigoqr/screen/finanzas.dart';
import 'package:codigoqr/screen/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localization/flutter_localization.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(
    ProviderScope(
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    localization.init(mapLocales: [
      const MapLocale('es', AppLocale.COP),
    ], initLanguageCode: 'es');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,
      title: 'Material App',
      initialRoute: 'splash',
      routes: {
        'splash': (BuildContext context) => LoadingPage(),
        'menu': (BuildContext context) => MenuScreen(),
        'finanzas': (BuildContext context) => FinanzasScreen(),
        'links': (BuildContext context) => LinksScreen(),
        'claves': (BuildContext context) => ClavesScreen(),
        'acercade': (BuildContext context) => AcercadeScreen(),
      },
    );
  }
}

mixin AppLocale {
  static const String title = 'title';
  static const Map<String, dynamic> COP = {title: 'Localizacion'};
}
