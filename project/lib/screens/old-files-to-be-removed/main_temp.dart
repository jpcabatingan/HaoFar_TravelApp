import 'package:flutter/material.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/screens/home_page.dart';
import 'package:project/screens/old-files-to-be-removed/les/signin_page.dart';
import 'package:project/screens/auth/signup_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

// firebase
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// other pubs
import 'package:google_fonts/google_fonts.dart';
import 'package:project/screens/auth/sign_up_travel_styles.dart';

// providers
import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;

// screens
import 'package:project/screens/auth/sign_in.dart';
import 'package:project/screens/auth/sign_up.dart';
import 'package:project/screens/auth/sign_up_interests.dart';

import 'package:project/screens/profile/profile.dart';
import 'package:project/screens/friends/friends.dart';

import 'package:project/screens/old-files-to-be-removed/mainwrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform, // Use the correct FirebaseOptions
  );

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 253, 248, 226),
        textTheme: GoogleFonts.lexendTextTheme(), // imported google fonts
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.lexend(
            color: const Color.fromARGB(255, 84, 89, 132),
          ),
        ),
      ),
      initialRoute: "",
      // routes of different pages
      routes: {
        '/': (context) => const Homepage(),
        '/signUp': (context) => const SignupPage(),
        '/signUpInterests': (context) => const SignUpInterests(),
        '/signUpTravelStyles': (context) => const SignUpTravelStyles(),
        '/homepage': (context) => const Homepage(),
      },
      // home: const Banner(
      //   message: 'Navigation Bar',
      //   location: BannerLocation.bottomStart,
      //   child: MainWrapper(),
      // ),
    );
  }
}
