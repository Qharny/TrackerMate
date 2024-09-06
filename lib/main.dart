import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackermate/services/shared_pref.dart';
import 'package:trackermate/services/location_service.dart';
import 'package:trackermate/screens/home.dart';
import 'package:trackermate/screens/auth/auth.dart';
import 'package:trackermate/screens/settings.dart';
import 'package:trackermate/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefsService.init();
  // await LocationService().initialize();
  runApp(const TrackMate());
}

class TrackMate extends StatelessWidget {
  const TrackMate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrackMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsScreen(),
      },
      initialRoute: '/',
    );
  }
}
