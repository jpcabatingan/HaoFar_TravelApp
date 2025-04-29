// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
// import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;

class SignUpInterests extends StatefulWidget {
  const SignUpInterests({super.key});

  @override
  State<SignUpInterests> createState() => _SignUpInterestsState();
}

class _SignUpInterestsState extends State<SignUpInterests> {
  //  app colors
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColorContinue = const Color.fromARGB(255, 163, 181, 101);
  final Color _btnColorSkip = const Color.fromARGB(255, 252, 221, 157);
  final Color _selectedColor = const Color.fromARGB(255, 241, 100, 46);

  final formkey = GlobalKey<FormState>();

  final List<String> _interests = [
    "Local Food",
    "Fancy Cuisine",
    "Locals",
    "Rich History",
    "Beaches",
    "Mountains",
    "Malls",
    "Festivals",
  ];

  final Set<String> _selectedInterests = {};

  void toggleSelection(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _createBody(context), backgroundColor: Colors.white,);
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
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "Interests",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: _titleColor,
                          letterSpacing: 1,
                          height: 1,
                        ),
                      ),
                    ),
                    Text("Select what you're interested in."),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(60.0),
                child: Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children:
                      _interests.map((interest) {
                        final isSelected = _selectedInterests.contains(
                          interest,
                        );
                        return GestureDetector(
                          onTap: () => toggleSelection(interest),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? _selectedColor
                                      : Colors.transparent, // ← FILL COLOR
                              border: Border.all(
                                color:
                                    isSelected
                                        ? _selectedColor
                                        : Colors.black54, // ← BORDER COLOR
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            _selectedInterests.isEmpty
                ? Padding(
                  padding: EdgeInsets.only(left: 60.0, right: 60.0),
                  child: _createSkipButton(context),
                )
                : Padding(
                  padding: EdgeInsets.only(left: 60.0, right: 60.0),
                  child: _createContinueButton(context),
                ),
          ],
        ),
      ),
    );
  }

  // sign-in button
  Widget _createSkipButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _btnColorSkip,
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
          print("Skip button pressed");
          Navigator.pushNamed(context, '/signUpTravelStyles');
        },
        child: const Text("SKIP"),
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
