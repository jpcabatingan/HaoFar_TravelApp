import 'package:flutter/material.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/screens/home_page.dart';
import 'package:project/screens/landing_page.dart';
import 'package:project/screens/signin_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform, // Use the correct FirebaseOptions
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: MyApp(),
    ),
  );
}

class AppRoutes {
  static const String homeRoute = '/';
  static const String signInRoute = '/sign-in';
  static const String landingRoute = '/landing-page';
  // add routs here
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.homeRoute:
        return MaterialPageRoute(builder: (_) => const Homepage());
      case AppRoutes.signInRoute:
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case AppRoutes.landingRoute:
        return MaterialPageRoute(builder: (_) => const LandingPage());
      default:
        // Handle unknown routes
        return MaterialPageRoute(builder: (_) => const Homepage());
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AppRoutes.homeRoute,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
