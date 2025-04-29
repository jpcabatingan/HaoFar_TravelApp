import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:project/providers/auth_provider.dart';

// firebase
// import 'package:firebase_auth/firebase_auth.dart';

// providers
import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formkey = GlobalKey<FormState>();

  // user info fields
  String firstName = "";
  String lastName = "";
  String email = "";
  String password = "";
  String confirmPassword = "";

  // error messages
  bool _errorDetectedEmail = false;
  bool _errorDetectedPassword = false;
  String _errorEmail = "";
  String _errorPassword = "";

  //  app colors
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);
  final Color _linkColor = const Color.fromARGB(255, 241, 100, 46);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _createBody());
  }

  Widget _createBody() {
    return Form(
      key: formkey,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // PAGE TITLE
                    Text(
                      "Create account",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: _titleColor,
                        letterSpacing: 1,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 10),
                    // SIGN-IN INSTEAD
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(text: 'Already have an account? '),
                          _createHyperlink('Sign-in'),
                          TextSpan(text: ' instead.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // FIRST NAME
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: _createTextField("First Name", Icons.face),
              ),

              SizedBox(height: 20),

              // LAST NAME
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: _createTextField("Last Name", Icons.face),
              ),

              SizedBox(height: 20),

              // EMAIL
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: _createTextField("Email", Icons.email_rounded),
              ),

              SizedBox(height: 20),

              // USERNAME
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: _createTextField("Username", Icons.person_rounded),
              ),

              SizedBox(height: 20),

              // PASSWORD
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: _createTextField("Password", Icons.password_rounded),
              ),

              SizedBox(height: 20),

              // CONFIRM PASSWORD
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: _createTextField(
                  "Confirm Password",
                  Icons.password_rounded,
                ),
              ),

              SizedBox(height: 30),

              // CREATE NEW ACCOUNT BUTTON
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: _createCreateAccountButton(context),
              ),
            ],
          ),
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
            ..onTap = () async {
              Navigator.pushNamed(context, '/signIn');
            },
    );
  }

  // reusable text field for form field inputs
  Widget _createTextField(String label, IconData icon) {
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

  // creates a new account and checks for input errors
  Widget _createCreateAccountButton(BuildContext context) {
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
          print(email);
          try {
            await Provider.of<AuthProvider>(
              context,
              listen: false,
            ).signUp(email, password, "sample", firstName, lastName);
            Navigator.pushNamed(context, '/homepage');
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
        child: const Text("SIGN UP Sana"),
      ),
    );
  }
}
