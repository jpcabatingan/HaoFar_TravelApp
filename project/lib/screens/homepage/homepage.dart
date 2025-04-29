// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
// import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //  app colors
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColorContinue = const Color.fromARGB(255, 163, 181, 101);

  final Color _cardMyColor = const Color.fromARGB(255, 241, 100, 46);
  final Color _textMyColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _cardSharedColor = const Color.fromARGB(255, 252, 221, 157);

  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _createBody(context));
  }

  Widget _createBody(BuildContext context) {
    return Form(
      key: formkey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          // spacing: 20,
          children: [
            Padding(
              padding: EdgeInsets.all(50.0),
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

            SizedBox(
              width: double.infinity,
              child: Padding(
              padding: EdgeInsets.all(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey there, JC!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: _titleColor,
                      letterSpacing: 1,
                      height: 1,
                    ),
                  ),
                  Text("Check out your latest travel plans below."),
                ],
              ),
            ),
            ),

            Card(
              color: _cardMyColor,
              elevation: 8,
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () {
                  print('Clicked my plans.');
                },
                child: SizedBox(
                  width: 400,
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text(
                      "MY PLANS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textMyColor,
                        letterSpacing: 1,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Card(
              color: _cardSharedColor,
              elevation: 8,
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () {
                  print('Clicked shared plans.');
                },
                child: SizedBox(
                  width: 400,
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text(
                      "Shared with me",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _cardMyColor,
                        letterSpacing: 1,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
