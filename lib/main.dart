// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:moapp_toto/firebase_options.dart';
// import 'package:moapp_toto/provider/toto_provider.dart';
// import 'package:moapp_toto/provider/user_provider.dart';
// import 'package:moapp_toto/screens/add/add_screen.dart';
// import 'package:moapp_toto/screens/edit/edit_screen.dart';
// import 'package:moapp_toto/screens/friend/friend_screen.dart';
// import 'package:moapp_toto/screens/home/home_screen.dart';
// import 'package:moapp_toto/screens/landing/landing_screen.dart';
// import 'package:moapp_toto/screens/mission/mission_screen.dart';
// import 'package:moapp_toto/screens/notification/notification_screen.dart';
// import 'package:moapp_toto/screens/profile/profile_screen.dart';
// import 'package:moapp_toto/screens/signUp/signUp_screen.dart';
// import 'package:provider/provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => TotoProvider()),
//         ChangeNotifierProvider(
//           create: (context) => UserProvider(),
//           lazy: false,
//         ),
//       ],
//       child: MaterialApp(
//         title: '투데이투게더',
//         initialRoute: '/landing',
//         navigatorKey: navigatorKey,
//         routes: {
//           '/landing': (BuildContext context) => LandingPage(),
//           '/signup': (BuildContext context) => const SignUpPage(),
//           '/': (BuildContext context) => const HomePage(),
//           '/add': (BuildContext context) => const AddPage(),
//           '/edit': (BuildContext context) => const EditPage(),
//           '/friend': (BuildContext context) => const FriendPage(),
//           '/notification': (BuildContext context) => const NotificationPage(),
//           '/mission': (BuildContext context) => const MissionPage(),
//           '/profile': (BuildContext context) => const ProfilePage(),
//         },
//         theme: ThemeData(
//           useMaterial3: true,
//           colorScheme: ColorScheme.fromSwatch().copyWith(
//             primary: const Color(0xFF363536),
//             surface: const Color(0xFFFFFFF5),
//           ),
//           scaffoldBackgroundColor: Colors.white,
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Color(0xFF363536),
//             foregroundColor: Color(0xFFFFFFF5),
//           ),
//           textTheme: const TextTheme(
//             bodyMedium: TextStyle(color: Colors.black),
//           ),
//           bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//             backgroundColor: Colors.white,
//             selectedItemColor: Colors.black,
//             unselectedItemColor: Color(0xFF363536),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:moapp_toto/firebase_options.dart';
import 'package:moapp_toto/provider/toto_provider.dart';
import 'package:moapp_toto/provider/user_provider.dart';
import 'package:moapp_toto/screens/add/add_screen.dart';
import 'package:moapp_toto/screens/edit/edit_screen.dart';
import 'package:moapp_toto/screens/friend/friend_screen.dart';
import 'package:moapp_toto/screens/home/home_screen.dart';
import 'package:moapp_toto/screens/landing/landing_screen.dart';
import 'package:moapp_toto/screens/mission/mission_screen.dart';
import 'package:moapp_toto/screens/notification/notification_screen.dart';
import 'package:moapp_toto/screens/profile/profile_screen.dart';
import 'package:moapp_toto/screens/signUp/signUp_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // AdaptiveTheme 초기화
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TotoProvider()),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
          lazy: false,
        ),
      ],
      child: AdaptiveTheme(
        light: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSwatch(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF363536),
            foregroundColor: Color(0xFFFFFFF5),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
          ),
          dividerColor: const Color.fromARGB(255, 245, 245, 245),
          iconTheme: const IconThemeData(color: Colors.black),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Color(0xFF363536),
          ),
        ),
        dark: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSwatch(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
          dividerColor: Colors.grey[800],
          iconTheme: IconThemeData(color: Colors.grey[200]),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF121212),
            selectedItemColor: Colors.white,
            unselectedItemColor: Color.fromARGB(255, 220, 206, 236),
          ),
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
          title: '투데이투게더',
          initialRoute: '/landing',
          navigatorKey: navigatorKey,
          routes: {
            '/landing': (BuildContext context) => LandingPage(),
            '/signup': (BuildContext context) => const SignUpPage(),
            '/': (BuildContext context) => const HomePage(),
            '/add': (BuildContext context) => const AddPage(),
            '/edit': (BuildContext context) => const EditPage(),
            '/friend': (BuildContext context) => const FriendPage(),
            '/notification': (BuildContext context) => const NotificationPage(),
            '/mission': (BuildContext context) => const MissionPage(),
            '/profile': (BuildContext context) => const ProfilePage(),
          },
          theme: theme,
          darkTheme: darkTheme,
        ),
        debugShowFloatingThemeButton: false,
      ),
    );
  }
}
