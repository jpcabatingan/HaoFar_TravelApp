import 'package:flutter/material.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignUpState();
}

class _SignUpState extends State<SignupPage> {
  final formkey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String username = "";
  String firstName = "";
  String lastName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: _createBody(context),
    );
  }

  Widget _createBody(BuildContext context) {
    return Form(
      key: formkey,
      child: Center(
        child: Column(
          children: [
            // USERNAME FIELD
            _createTextField((value) {
              username = value;
            }, "Username"),
            // FIRST NAME FIELD
            _createTextField((value) {
              firstName = value;
            }, "First Name"),
            // LAST NAME FIELD
            _createTextField((value) {
              lastName = value;
            }, "Last Name"),
            // EMAIL FIELD
            _createTextField((value) {
              email = value;
            }, "Email"),
            // PASSWORD FIELD
            _createTextField((value) {
              password = value;
            }, "Password"),
            // SIGN UP BUTTON
            _createSignUpButton(context),
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

  Widget _createSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (formkey.currentState!.validate()) {
          try {
            await Provider.of<AuthProvider>(
              context,
              listen: false,
            ).signUp(email, password, username, firstName, lastName);
            Navigator.pushNamed(context, '/interests');
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      },
      child: const Text('Sign Up'),
    );
  }
}
