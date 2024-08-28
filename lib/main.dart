import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trackermate/screens/home.dart';
// import 'package:trackermate/route.dart';
import 'package:trackermate/services/shared_pref.dart';

import 'screens/auth/auth.dart';
import 'screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefsService.init();
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
      },
      initialRoute: '/',
      // onGenerateRoute: AppRoutes.generateRoute,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
