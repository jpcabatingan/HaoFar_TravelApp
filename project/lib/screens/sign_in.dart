// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //  app colors
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);
  final Color _linkColor = const Color.fromARGB(255, 241, 100, 46);

  final formkey = GlobalKey<FormState>();

  // user credentials
  String username = "";
  String password = "";

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
          spacing: 20,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 35.0, bottom: 35.0),
              child: Text(
                "Travel App",
                style: GoogleFonts.boogaloo(
                  textStyle: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: _titleColor,
                    letterSpacing: 1,
                    height: 1,
                  ),
                ),
              ),
            ),

            // USERNAME FIELD
            Padding(
              padding: EdgeInsets.only(left: 60.0, right: 60.0),
              child: _createTextFormField("Username", Icons.person_rounded),
            ),

            // PASSWORD FIELD
            Padding(
              padding: EdgeInsets.only(left: 60.0, right: 60.0),
              child: _createTextFormField("Password", Icons.password_rounded),
            ),

            // SIGN IN BUTTON
            Padding(
              padding: EdgeInsets.only(left: 60.0, right: 60.0),
              child: _createSignInButton(context),
            ),

            SizedBox(height: 20),

            // SIGN-UP INSTEAD
            Padding(
              padding: EdgeInsets.all(16.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(text: 'No account yet? '),
                    _createHyperlink('Sign Up'),
                    TextSpan(text: ' instead.'),
                  ],
                ),
              ),
            ),

            _createSignUpButton(),
          ],
        ),
      ),
    );
  }

  TextSpan _createHyperlink(String linkText) {
    return TextSpan(
      text: linkText,
      style: TextStyle(
        color: _linkColor,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.bold,
      ),
      recognizer:
          TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushNamed(context, '/signUp');
            },
    );
  }

  // reusable text form field
  Widget _createTextFormField(String label, IconData icon) {
    return TextFormField(
      initialValue: "",
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _labelsColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _fieldColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _fieldColor),
        ),
        prefixIcon: Icon(icon, color: _labelsColor),
        filled: true,
        fillColor: _fieldColor,
      ),
      style: TextStyle(
        fontSize: 14,
        color: const Color.fromARGB(255, 84, 89, 132),
      ),
    );
  }

  // sign-in button
  Widget _createSignInButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _btnColor,
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
        onPressed: () async {
          await context.read<AuthProvider>().signIn(username, password);
          print("User signed in: $username");

          Navigator.pushNamed(context, '/homepage');
        },
        child: const Text("LOG IN Testing"),
      ),
    );
  }

  Widget _createSignUpButton() {
    return TextButton(
      onPressed: () {
        // Navigate to sign-up page
        Navigator.pushNamed(context, '/signUp');
      },
      child: const Text('Sign Up Testing'),
    );
  }
}
