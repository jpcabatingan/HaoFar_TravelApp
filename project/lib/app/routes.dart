import 'package:flutter/material.dart';
import 'package:project/screens/auth/auth_wrapper.dart';
import 'package:project/screens/auth/sign_in.dart';
import 'package:project/screens/auth/sign_up.dart';
import 'package:project/screens/auth/sign_up_interests.dart';
import 'package:project/screens/auth/sign_up_travel_styles.dart';
import 'package:project/screens/errors/not_found_page.dart';
import 'package:project/screens/profile/profile.dart';
import 'package:project/screens/friends/friends.dart';
import 'package:project/screens/travel-plan/shareqr.dart';

class AppRoutes {
  // Auth
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String signUpInterest = '/sign-up-interests';
  static const String signUpTravelStyle = '/sign-up-travel-styles';

  // Main App
  static const String home = '/';
  static const String travelList = '/travel-list';
  static const String travelListDetails = '/travel-list-details';
  static const String travelListDetailsEdit = '/travel-list-details-edit';
  static const String createTravelPlan = '/new-travel-list';
  static const String createTravelPlanExtra = '/new-travel-list-extra';
  static const String shareQR = '/shareqr';
  static const String scanQR = '/scanqr';
  static const String friends = '/friends';
  static const String profile = '/profile';
  static const String notFound = '/not-found';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.signIn:
      // return MaterialPageRoute(builder: (_) => const SignIn());
      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUp());
      case AppRoutes.signUpInterest:
        return MaterialPageRoute(builder: (_) => const SignUpInterests());
      case AppRoutes.signUpTravelStyle:
        return MaterialPageRoute(builder: (_) => const SignUpTravelStyles());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => Profile());
      case AppRoutes.friends:
        return MaterialPageRoute(builder: (_) => Friends());
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
