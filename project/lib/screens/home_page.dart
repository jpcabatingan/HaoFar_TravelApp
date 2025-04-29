import 'package:flutter/material.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/screens/signin_page.dart';
import 'package:project/screens/travel_list_page.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    var user = context.watch<AuthProvider>().user;
    return user == null ? SignInPage() : const TravelListPage();
  }
}
