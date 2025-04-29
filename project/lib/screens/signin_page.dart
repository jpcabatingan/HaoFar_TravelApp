import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final formkey = GlobalKey<FormState>();
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: _createBody(context),
    );
  }

  Widget _createBody(BuildContext context) {
    return Form(
      key: formkey,
      child: Center(
        child: Column(
          children: [
            // EMAIL FIELD
            _createTextField((value) {
              email = value;
            }, "Email"),
            // PASSWORD FIELD
            _createTextField((value) {
              password = value;
            }, "Password"),
            // SIGN IN BUTTON
            _createSignInButton(context),
            _createSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _createTextField(Function(String) onChanged, String label) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget _createSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (formkey.currentState!.validate()) {
          // Perform sign-in action
          Navigator.pushNamed(context, '/home');
        }
      },
      child: const Text('Sign In'),
    );
  }

  Widget _createSignUpButton() {
    return TextButton(
      onPressed: () {
        // Navigate to sign-up page
        Navigator.pushNamed(context, '/sign-up');
      },
      child: const Text('Sign Up'),
    );
  }
}
