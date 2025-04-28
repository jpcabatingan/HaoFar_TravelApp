import 'package:flutter/material.dart';

// firebase
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// other pubs
import 'package:google_fonts/google_fonts.dart';

// providers
import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;

// screens
import 'package:project/screens/sign_in.dart';
import 'package:project/screens/sign_up.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const MyApp()
    // MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: (_) => authprov.AuthProvider()),
    //     ChangeNotifierProxyProvider<authprov.AuthProvider, ExpenseProvider>(
    //       create:
    //           (context) =>
    //               ExpenseProvider(context.read<authprov.AuthProvider>()),
    //       update: (context, auth, previous) => ExpenseProvider(auth),
    //     ),
    //   ],
    //   child: const MyApp(),
    // ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 253,248,226),
        textTheme: GoogleFonts.poppinsTextTheme(), // imported google fonts
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 84, 89, 132),
          ),
        ),
      ),
      initialRoute: "/",
      // routes of different pages
      routes: {
        '/': (context) => const SignIn(),
        '/signIn': (context) => const SignIn(),
        '/signUp': (context) => const SignUp(),
      },
    );
  }
}
