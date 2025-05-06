// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;
import 'package:project/providers/travel_plan_provider.dart';

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/newPlan');
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: const Color(0xFFF6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EEF8),
        elevation: 0,
        title: const Text(
          'Traveler',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Hey there, JC!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.grey),
                child: Stack(
                  children: const [
                    Center(
                      child: Icon(Icons.image, size: 80, color: Colors.white70),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Text(
                        'Top Travel Destinations in 2025',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black45,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<TravelPlanProvider>().setFilterCategory("none");
                Navigator.pushNamed(context, '/travelPlans');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'See all travel plans',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _verticalPlanCard('MY PLANS', () {
              context.read<TravelPlanProvider>().setFilterCategory("my");
              Navigator.pushNamed(context, '/travelPlans');
            }),
            const SizedBox(height: 16),
            _verticalPlanCard('SHARED WITH ME', () {
              context.read<TravelPlanProvider>().setFilterCategory("shared");
              Navigator.pushNamed(context, '/travelPlans');
            }),
          ],
        ),
      ),
    );
  }

  Widget _verticalPlanCard(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFEDE0F4),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.change_history, size: 24, color: Colors.grey),
                    SizedBox(height: 4),
                    Icon(Icons.square, size: 20, color: Colors.grey),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 28, color: Colors.grey),
              ],
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
