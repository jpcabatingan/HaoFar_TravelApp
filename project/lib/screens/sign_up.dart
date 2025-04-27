import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // app colors
  final Color _titleColor = const Color.fromARGB(255, 109, 68, 171);
  final Color _labelsColor = const Color.fromARGB(255, 96, 101, 145);
  final Color _fieldColor = const Color.fromARGB(255, 232, 231, 244);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(foregroundColor: Colors.blue),
      body: _createBody(),
    );
  }

  Widget _createBody() {
    return Form(
      key: formkey,
      child: Center(
        child: Column(
          spacing: 20,
          children: [

            // PAGE TITLE
            Padding(
              padding: EdgeInsets.only(top: 35.0, bottom: 10.0),
              child: Text(
                "Create account",
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

            // FIRST NAME
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              child: _createTextField(
                "First Name",
                Icons.face,
              ),
            ),

            // LAST NAME
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              child: _createTextField(
                "Last Name",
                Icons.face,
              ),
            ),

            // EMAIL
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              child: _createTextField(
                "Email",
                Icons.email_rounded,
              ),
            ),

            // USERNAME
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              child: _createTextField(
                "Username",
                Icons.person_rounded,
              ),
            ),

            // PASSWORD
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              child: _createTextField(
                "Password",
                Icons.password_rounded,
              ),
            ),

            // CONFIRM PASSWORD
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              child: _createTextField(
                "Confirm Password",
                Icons.password_rounded,
              ),
            ),

            // CREATE NEW ACCOUNT
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              child: _createCreateAccountButton(context),
            ),

            // SIGN UP INSTEAD
            Text("Already have an account? Sign in instead."),
            Padding(
              padding: EdgeInsets.only(left: 60.0, right: 60.0),
              child: _createSignInButton(),
            ),
          ],
        ),
      ),
    );
  }

  // sign-in button
  Widget _createSignInButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/signIn');
      },
      child: const Text("Sign in"),
    );
  }

  // reusable text field for form field inputs
  Widget _createTextField(
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

  // creates a new account and checks for input errors
  Widget _createCreateAccountButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {
        print("nothing")
      },
      child: const Text("Sign Up"),
    );
  }
}
