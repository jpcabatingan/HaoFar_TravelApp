import 'package:flutter/material.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class TravelListPage extends StatefulWidget {
  const TravelListPage({super.key});

  @override
  State<TravelListPage> createState() => _TravelListPageState();
}

class _TravelListPageState extends State<TravelListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel List')),
      body: Center(child: Text('Travel List Page')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pop(context);
          await context.read<AuthProvider>().signOut();
          Navigator.pushReplacementNamed(context, "/");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
