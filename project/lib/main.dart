import 'package:flutter/material.dart';
import 'package:project/api/travel_plan_api.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:project/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => TravelPlanProvider(FirebaseTravelPlanApi()),
        ),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFFDF8E6),
      textTheme: GoogleFonts.lexendTextTheme(),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.lexend(fontSize: 12),
        ),
      ),
    );
  }
}
