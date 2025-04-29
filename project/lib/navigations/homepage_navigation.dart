import 'package:flutter/material.dart';

import 'package:project/screens/homepage/homepage.dart';
import 'package:project/screens/profile/profile.dart';
import 'package:project/screens/friends/friends.dart';

class HomepageNavigator extends StatefulWidget {
  const HomepageNavigator({super.key});

  @override
  HomepageNavigatorState createState() => HomepageNavigatorState();
}

GlobalKey<NavigatorState> updatesNavigatorKey = GlobalKey<NavigatorState>();

class HomepageNavigatorState extends State<HomepageNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: updatesNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            // if (settings.name == "/detailsHomepage") {
            //   return const DetailsHomepageView();
            // }
            return const Homepage();
          },
        );
      },
    );
  }
}
