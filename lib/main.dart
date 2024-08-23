import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TrackMate());
}

class TrackMate extends StatelessWidget {
  const TrackMate({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // initialRoute: AppRoutes.login,
      // onGenerateRoute: AppRoutes.generateRoute,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
