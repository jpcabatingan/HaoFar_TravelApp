// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  //  app colors
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColorContinue = const Color.fromARGB(255, 163, 181, 101);
  final Color _btnColorSkip = const Color.fromARGB(255, 252, 221, 157);
  final Color _selectedColor = const Color.fromARGB(255, 241, 100, 46);

  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _createBody(context));
  }

  Widget _createBody(BuildContext context) {
    return Form(
      key: formkey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // spacing: 20,
          children: [
            Padding(
              padding: EdgeInsets.all(0.0),
              child: Text(
                "Discover Friends",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: _titleColor,
                  letterSpacing: 1,
                  height: 1,
                ),
              ),
            ),
            Text("Select travel plans category."),
            // MY PLANS
            // SHARED WITH ME
          ],
        ),
      ),
    );
  }

  // continue button
  Widget _createContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _btnColorContinue,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.black26, width: 1),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          elevation: 2,
        ),
        onPressed: () {
          print("Continue button pressed");
          Navigator.pushNamed(context, '/signUpTravelStyles');
        },
        child: const Text("CONTINUE"),
      ),
    );
  }
}
