// import 'package:flutter/material.dart';


// class AppRoutes {
//   static const String login = '/login';
//   static const String home = '/home';
//   static const String settings = '/settings';

//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case login:
//         return MaterialPageRoute(builder: (_) => LoginScreen());
//       case home:
//         return MaterialPageRoute(builder: (_) => HomeScreen());
//       case settings:
//         return MaterialPageRoute(builder: (_) => SettingsScreen());
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