import 'package:flutter/material.dart';
import 'package:project/app/routes.dart';
import 'package:project/screens/errors/not_found_page.dart';
import 'package:project/screens/friends/friends.dart';
import 'package:project/screens/travel-plan/new_plan_extra.dart';
import 'package:project/screens/travel-plan/new_plan.dart';
import 'package:project/screens/profile/profile.dart';
import 'package:project/screens/travel-plan/edit_plan.dart';
import 'package:project/screens/travel-plan/plan_details.dart';
import 'package:project/screens/travel-plan/scanqr.dart';
import 'package:project/screens/travel-plan/shareqr.dart';
import 'package:project/screens/travel-plan/travel_plans_list.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  AppLayoutState createState() => AppLayoutState();
}

class AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<String> _initialRoutes = [
    AppRoutes.travelList,
    AppRoutes.friends,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handleBackButton(),
      child: Scaffold(
        bottomNavigationBar: _buildNavigationBar(),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTabNavigator(0),
            _buildTabNavigator(1),
            _buildTabNavigator(2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      initialRoute: _initialRoutes[index],
      onGenerateRoute:
          (settings) => MaterialPageRoute(
            builder: (context) => _generateNestedRoute(settings),
            settings: settings,
          ),
    );
  }

  Widget _generateNestedRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.travelList:
        return const TravelPlans();
      case AppRoutes.travelListDetails:
        return const PlanDetails();
      case AppRoutes.travelListDetailsEdit:
        return const EditPlan();
      case AppRoutes.shareQR:
        return const ShareQR();
      case AppRoutes.scanQR:
        return const QrScannerScreen();
      case AppRoutes.createTravelPlan:
        return const NewPlan();
      case AppRoutes.createTravelPlanExtra:
        return const NewPlanExtra();
      case AppRoutes.friends:
        return const Friends();
      case AppRoutes.profile:
        return const Profile();
      default:
        return const NotFoundPage();
    }
  }

  NavigationBar _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Trips',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'Friends',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outlined),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Future<bool> _handleBackButton() async {
    final currentNavigator = _navigatorKeys[_selectedIndex].currentState;
    if (currentNavigator?.canPop() ?? false) {
      currentNavigator?.pop();
      return false;
    }

    // Handle root navigator if needed
    final shouldExit = await _confirmExit();
    if (shouldExit && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    return false;
  }

  Future<bool> _confirmExit() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Exit App?'),
                content: const Text('Do you want to exit the application?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
