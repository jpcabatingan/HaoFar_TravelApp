import 'package:flutter/material.dart';
import 'package:project/screens/auth/auth_wrapper.dart';
import 'package:project/screens/auth/sign_in.dart';
import 'package:project/screens/auth/sign_up.dart';
import 'package:project/screens/errors/not_found_page.dart';
import 'package:project/screens/friends/friends.dart';
import 'package:project/screens/profile/profile.dart';
import 'package:project/screens/travel-plan/travel_list_page.dart';

class AppRoutes {
  // Auth
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  // Main App
  static const String home = '/';
  static const String travelList = '/travel-list';
  static const String friends = '/friends';
  static const String profile = '/profile';
  static const String notFound = '/not-found';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => const SignIn());
      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUp());
      // case AppRoutes.travelList:
      //   return MaterialPageRoute(builder: (_) => const TravelListPage());
      // case AppRoutes.friends:
      //   return MaterialPageRoute(builder: (_) => const Friends());
      // case AppRoutes.profile:
      //   return MaterialPageRoute(builder: (_) => const Profile());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case AppRoutes.notFound:
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
          settings: settings,
        );
    }
  }
}
