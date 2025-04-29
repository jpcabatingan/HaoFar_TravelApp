import 'package:flutter/material.dart';
import 'package:project/screens/homepage/homepage.dart';
import 'package:project/screens/profile/profile.dart';
import 'package:project/screens/friends/friends.dart';

class FriendsNavigator extends StatefulWidget {
  const FriendsNavigator({super.key});

  @override
  FriendsNavigatorState createState() => FriendsNavigatorState();
}

GlobalKey<NavigatorState> wishListNavigatorKey = GlobalKey<NavigatorState>();

class FriendsNavigatorState extends State<FriendsNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: wishListNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            settings: settings,
            builder: (BuildContext context) {
              // if (settings.name == "/detailsFriendsNavigator") {
              //   return const DetailsFriendsNavigatorView();
              // }
              return const Friends();
            });
      },
    );
  }
}
