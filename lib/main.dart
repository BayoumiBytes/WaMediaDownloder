import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mediadownloader/Screens/Home.dart';
import 'package:mediadownloader/Screens/StatusPage.dart';
import 'package:mediadownloader/manager/InterstitialAdManager.dart';
import 'package:mediadownloader/widgets/main_navigation.dart';

void main() async {
  if (AppConfig.showAds) {
    WidgetsFlutterBinding.ensureInitialized();
    await MobileAds.instance.initialize();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['528B17CC97DE9D97C2472276DD236CE7']),
    );
    InterstitialAdManager().initialize();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Media Downloader",
      theme: ThemeData(
        primaryColor: Colors.lightBlue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      routes: {
        // '/home': (context) => const Home(),
        '/home': (context) => const Home(),
        '/status': (context) => const StatusPage(),
      },
      home: const MainNavigation(),
    );
  }
}

class AppConfig {
  static bool get showAds {
    return kDebugMode ? true : _getFlavorAds();
  }

  static bool _getFlavorAds() {
    const flavor = String.fromEnvironment('FLAVOR');
    return flavor == 'free';
  }
}
