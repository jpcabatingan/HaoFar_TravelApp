import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:project/providers/user_provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // app colors
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 246, 230);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);
  final Color _linkColor = const Color.fromARGB(255, 241, 100, 46);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0.0, bottom: 35.0),
                  child: Image.asset('assets/logo.png', height: 150),
                ),

                // USERNAME FIELD
                _buildTextField(
                  _usernameController,
                  "Username",
                  Icons.person_rounded,
                ),
                const SizedBox(height: 20),

                // PASSWORD FIELD
                _buildTextField(
                  _passwordController,
                  "Password",
                  Icons.password_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // SIGN IN BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: _createSignInButton(context),
                ),
                const SizedBox(height: 20),

                // SIGN-UP INSTEAD
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        const TextSpan(text: 'No account yet? '),
                        _createHyperlink('Sign Up'),
                        const TextSpan(text: ' instead.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
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
      ),
    );
  }

  Widget _createSignInButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _linkColor,
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
          if (formKey.currentState!.validate()) {
            try {
              await Provider.of<AuthProvider>(
                context,
                listen: false,
              ).signInWithUsername(
                _usernameController.text.trim(),
                _passwordController.text,
              );
              //Fetch the fresh user data
              final uid = FirebaseAuth.instance.currentUser!.uid;
              await Provider.of<UserProvider>(
                context,
                listen: false,
              ).fetchUser(uid);
              Navigator.pushNamed(context, '/');
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          }
        },
        child: const Text("LOG IN"),
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
            ..onTap = () => Navigator.pushNamed(context, '/sign-up'),
    );
  }
}
