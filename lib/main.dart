import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trackermate/screens/home.dart';
// import 'package:trackermate/route.dart';
import 'package:trackermate/services/shared_pref.dart';

import 'screens/auth/auth.dart';
import 'screens/settings.dart';
import 'screens/splash.dart';
import 'services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefsService.init();
  await LocationService.initialize();
  runApp(const TrackMate());
}

class TrackMate extends StatelessWidget {
  const TrackMate({super.key});

  // This widget is the root of your application.
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
      // onGenerateRoute: AppRoutes.generateRoute,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
