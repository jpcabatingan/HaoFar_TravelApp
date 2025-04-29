import 'package:flutter/material.dart';
import 'package:project/screens/maryz/homepage/homepage.dart';
import 'package:project/screens/maryz/profile/profile.dart';
import 'package:project/screens/maryz/friends/friends.dart';

class ProfileNavigator extends StatefulWidget {
  const ProfileNavigator({super.key});

  @override
  ProfileNavigatorState createState() => ProfileNavigatorState();
}

GlobalKey<NavigatorState> wishListNavigatorKey = GlobalKey<NavigatorState>();

class ProfileNavigatorState extends State<ProfileNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: wishListNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            // if (settings.name == "/detailsProfileNavigator") {
            //   return const DetailsProfileNavigatorView();
            // }
            return const Profile();
          },
        );
      },
    );
  }
}
