// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //  app colors
  final Color _labelsColor = const Color.fromARGB(255, 96, 101, 145);
  final Color _fieldColor = const Color.fromARGB(255, 232, 231, 244);
  final Color _titleColor = const Color.fromARGB(255, 109, 68, 171);

  final formkey = GlobalKey<FormState>();

  // user credentials
  String username = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(foregroundColor: Colors.blue),
      body: _createBody(context),
    );
  }

  Widget _createBody(BuildContext context) {
    return Form(
      key: formkey,
      child: Center(
        child: Column(
          spacing: 10,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 35.0),
              child: Text(
                "TRAVEL",
                style: GoogleFonts.dmSerifText(
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
              child: _createTextFormField(
                "Username",
                Icons.person_rounded,
              ),
            ),

            // PASSWORD FIELD
            Padding(
              padding: EdgeInsets.only(left: 60.0, right: 60.0),
              child: _createTextFormField(
                "Password",
                Icons.password_rounded,
              ),
            ),

            SizedBox(height: 20),

            // SIGN IN BUTTON
            Padding(
              padding: EdgeInsets.only(left: 60.0, right: 60.0),
              child: _createSignInButton(context),
            ),

            SizedBox(height: 20),

            // SIGN UP INSTEAD
            Text("Don't have an account yet? Sign up instead."),
            Padding(
              padding: EdgeInsets.only(left: 60.0, right: 60.0),
              child: _createSignUpButton(),
            ),
          ],
        ),
      ),
    );
  }

  // reusable text form field
  Widget _createTextFormField(
    String label,
    IconData icon,
  ) {
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

  // sign-up button
  _createSignUpButton() {
    return OutlinedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/signUp');
      },
      child: const Text("Sign up"),
    );
  }

  // sign-in button
  Widget _createSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {
        print("nothing")
      },
      child: const Text("Sign In"),
    );
  }
}
