// Sign up Travel Styles page
// user can select their preferred travel styles

import 'package:flutter/material.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'hide AuthProvider;
import 'package:project/providers/user_provider.dart';

class SignUpTravelStyles extends StatefulWidget {
  const SignUpTravelStyles({super.key});

  @override
  State<SignUpTravelStyles> createState() => _SignUpTravelStylesState();
}

class _SignUpTravelStylesState extends State<SignUpTravelStyles> {
  //  app colors
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColorContinue = const Color.fromARGB(255, 163, 181, 101);
  final Color _btnColorSkip = const Color.fromARGB(255, 252, 221, 157);
  final Color _selectedColor = const Color.fromARGB(255, 241, 100, 46);

  final formkey = GlobalKey<FormState>();

  final List<String> _travelStyles = [
    "Solo",
    "Group",
    "Backpacking",
    "Long-Term",
    "Short-Term",
  ];

  final Set<String> _selectedTravelStyles = {};

  void toggleSelection(String travelStyle) {
    setState(() {
      if (_selectedTravelStyles.contains(travelStyle)) {
        _selectedTravelStyles.remove(travelStyle);
      } else {
        _selectedTravelStyles.add(travelStyle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _createBody(context), backgroundColor: Colors.white);
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
                        "Travel Styles",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: _titleColor,
                          letterSpacing: 1,
                          height: 1,
                        ),
                      ),
                    ),
                    Text("Select your travel style."),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(60.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 15,
                  runSpacing: 15,
                  children:
                      _travelStyles.map((travelStyle) {
                        final isSelected = _selectedTravelStyles.contains(
                          travelStyle,
                        );
                        return GestureDetector(
                          onTap: () => toggleSelection(travelStyle),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? _selectedColor
                                      : Colors.transparent, 
                              border: Border.all(
                                color:
                                    isSelected
                                        ? _selectedColor
                                        : Colors.black54,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              travelStyle,
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

            _selectedTravelStyles.isEmpty
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

  // skip button
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
        onPressed: () async {
          print("Skip button pressed");
          final uid = FirebaseAuth.instance.currentUser!.uid;
          await Provider.of<UserProvider>(context, listen: false).fetchUser(uid);
          Navigator.pushNamed(context, '/');
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
        onPressed: () async {
          try {
            await Provider.of<AuthProvider>(context, listen: false)
                .updateTravelStyles(_selectedTravelStyles.toList());
            // re-fetch the full user doc (now including interests + travelStyles)
            final uid = FirebaseAuth.instance.currentUser!.uid;
            await Provider.of<UserProvider>(context, listen: false).fetchUser(uid);
            Navigator.pushNamed(context, '/');
          } catch (e) {
            ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
        child: const Text(
          "Finish Sign Up",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
