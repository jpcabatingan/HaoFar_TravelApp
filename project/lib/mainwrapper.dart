import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_nested_persistance_navigation/navigations/updates_navigation.dart';
// import 'package:flutter_nested_persistance_navigation/navigations/wishlists_navigation.dart';

import 'package:project/navigations/homepage_navigation.dart';
import 'package:project/navigations/friends_navigation.dart';
import 'package:project/navigations/profile_navigation.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  MainWrapperState createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    // wishListNavigatorKey,
    // updatesNavigatorKey,
  ];

  Future<bool> _systemBackButtonPressed() async {
    if (_navigatorKeys.isNotEmpty &&
        _navigatorKeys[_selectedIndex].currentState?.canPop() == true) {
      _navigatorKeys[_selectedIndex].currentState?.maybePop();
      return false;
    } else {
      await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _systemBackButtonPressed();
        }
      },
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedIndex: _selectedIndex,
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.people_alt),
              icon: Icon(Icons.people_alt_outlined),
              label: 'Friends',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(Icons.person_outlined),
              label: 'Profile',
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: _selectedIndex,
            // children: [
            //   Container(
            //     color: Colors.red,
            //   ),
            //   Container(
            //     color: Colors.amber,
            //   ),
            //   Container(
            //     color: Colors.green,
            //   )
            // ],
            children: const <Widget>[
              /// First Route  
              HomepageNavigator(),

              /// Second Route
              FriendsNavigator(),

              // Third Route
              ProfileNavigator(),
            ],
          ),
        ),
      ),
    );
  }
}
