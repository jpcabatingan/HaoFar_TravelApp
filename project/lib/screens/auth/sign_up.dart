import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // app colors
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);
  final Color _linkColor = const Color.fromARGB(255, 241, 100, 46);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            const TextSpan(text: 'Already have an account? '),
                            _createHyperlink('Sign-in'),
                            const TextSpan(text: ' instead.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // FIRST NAME
                _buildTextField(_firstNameController, "First Name", Icons.face),
                const SizedBox(height: 20),

                // LAST NAME
                _buildTextField(_lastNameController, "Last Name", Icons.face),
                const SizedBox(height: 20),

                // EMAIL
                _buildTextField(
                  _emailController,
                  "Email",
                  Icons.email_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email required';
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // USERNAME
                _buildTextField(
                  _usernameController,
                  "Username",
                  Icons.person_rounded,
                ),
                const SizedBox(height: 20),

                // PASSWORD
                _buildTextField(
                  _passwordController,
                  "Password",
                  Icons.password_rounded,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Password required';
                    if (value.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // CONFIRM PASSWORD
                _buildTextField(
                  _confirmPasswordController,
                  "Confirm Password",
                  Icons.password_rounded,
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // SIGN UP BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: _createSignUpButton(context),
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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
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

  Widget _createSignUpButton(BuildContext context) {
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
          if (formKey.currentState!.validate()) {
            try {
              await Provider.of<AuthProvider>(context, listen: false).signUp(
                _emailController.text.trim(),
                _passwordController.text,
                _usernameController.text.trim(),
                _firstNameController.text.trim(),
                _lastNameController.text.trim(),
              );
              Navigator.pushNamed(context, '/travel-list');
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          }
        },
        child: const Text("SIGN UP"),
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
            ..onTap = () => Navigator.pushNamed(context, '/sign-in'),
    );
  }
}
