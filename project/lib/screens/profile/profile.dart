import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoButton(
              color: const Color.fromARGB(255, 210, 52, 52),
              borderRadius: BorderRadius.circular(15),
              child: const Text("Go To Details Wishlist"),
              onPressed: () => {
                print("Clicked Button")
              },
            ),
          ],
        ),
      ),
    );
  }
}
