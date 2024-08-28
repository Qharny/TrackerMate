// import 'package:flutter/material.dart';
// import 'package:trackermate/screens/auth/auth.dart';
// import 'package:trackermate/screens/home.dart';
// import 'package:trackermate/screens/settings.dart';

// class AppRoutes {
//   static const String login = '/login';
//   static const String home = '/home';
//   static const String settings = '/settings';

//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case login:
//         return MaterialPageRoute(builder: (_) => const AuthScreen());
//       case home:
//         return MaterialPageRoute(builder: (_) => const HomePage());
//       case settings:
//         return MaterialPageRoute(builder: (_) => const SettingsPage());
//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(
//               child: Text('No route defined for ${settings.name}'),
//             ),
//           ),
//         );
//     }
//   }
// }