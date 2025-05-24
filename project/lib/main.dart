import 'package:flutter/material.dart';
import 'package:project/api/travel_plan_api.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:project/providers/user_provider.dart';
import 'package:project/services/notification_service.dart'; // Import the service
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/app/routes.dart';

// Declare notificationService globally or pass it down if preferred
// Making it global for simplicity in this example, but consider dependency injection for larger apps.
// final NotificationService notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the notification service after Firebase.initializeApp()
  try {
    // await notificationService.initialize();
  } catch (e) {
    print("Error initializing notification service: $e");
    // Handle error appropriately, maybe log to a crashlytics service
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => TravelPlanProvider(FirebaseTravelPlanApi()),
        ),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        // Provider<NotificationService>(create: (_) => notificationService), // Optionally provide if needed in widgets
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
      theme: _buildTheme(context), // Pass context to _buildTheme
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home, // Assuming AuthWrapper is home
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    // Added context parameter
    return ThemeData(
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      textTheme: GoogleFonts.robotoTextTheme(
        Theme.of(context).textTheme, // Apply Roboto to the existing theme
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.roboto(fontSize: 12),
        ),
      ),
      primaryColor: const Color(0xFFF1642E), // A common primary color
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFF1642E), // Primary color for the scheme
        secondary: const Color(0xFFA3B565), // A secondary color
        // You can define more colors like error, surface, background etc.
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF1642E), // Default button background
          foregroundColor: Colors.white, // Default button text color
          textStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // Consistent input field styling
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFFF1642E), width: 2),
        ),
        labelStyle: GoogleFonts.roboto(color: Colors.black54),
        hintStyle: GoogleFonts.roboto(color: Colors.grey.shade500),
      ),
      // Add other theme properties as needed
    );
  }
}
