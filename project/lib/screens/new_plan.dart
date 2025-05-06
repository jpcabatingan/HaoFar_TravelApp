import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'new_plan_extra.dart';
import 'package:project/models/travel_plan.dart';
import 'package:provider/provider.dart';

class NewPlan extends StatefulWidget {
  const NewPlan({super.key});

  @override
  State<NewPlan> createState() => _NewPlanState();
}

class _NewPlanState extends State<NewPlan> {
  // final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  // final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  // final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);
  // final Color _cardMyColor = const Color.fromARGB(255, 241, 100, 46);
  // final Color _textMyColor = const Color.fromARGB(255, 255, 255, 255);
  // final Color _cardSharedColor = const Color.fromARGB(255, 252, 221, 157);

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;

  Map<String, dynamic> moreInfo = {};

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EEF8),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Traveler', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Create new plan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : DateFormat.yMMMMd().format(_selectedDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                suffixIcon: const Icon(Icons.location_on),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                _addMoreInfo(context);
                print("Adding more info");
                Navigator.pushNamed(context, '/newPlanExtra');
              },
              child: const Text(
                'Add more info',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 20),
            _createDoneButton(context),
          ],
        ),
      ),
    );
  }

  // done button
  Widget _createDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _btnColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.black26, width: 1),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          elevation: 2,
        ),
        onPressed: () {
          _savePlan(context);
          print("Created new plan");
          Navigator.pushNamed(context, '/homepage');
        },
        child: const Text("DONE"),
      ),
    );
  }

  void _addMoreInfo(BuildContext context) {
    if (_titleController.text.isEmpty ||
        _selectedDate == null ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final newPlan = TravelPlanModel(
      title: _titleController.text,
      date: _selectedDate!,
      location: _locationController.text,
      category: 'my',
      flight: moreInfo['flight'],
      accommodation: moreInfo['accommodation'],
      itinerary: moreInfo['itinerary'],
      notes: moreInfo['notes'],
      checklist: moreInfo['checklist'],
    );

    context.read<TravelPlanProvider>().setCurrentlyAdding(newPlan);
  }

  void _savePlan(BuildContext context) {
    if (_titleController.text.isEmpty ||
        _selectedDate == null ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final newPlan = TravelPlanModel(
      title: _titleController.text,
      date: _selectedDate!,
      location: _locationController.text,
      category: 'my',
      flight: moreInfo['flight'],
      accommodation: moreInfo['accommodation'],
      itinerary: moreInfo['itinerary'],
      notes: moreInfo['notes'],
      checklist: moreInfo['checklist'],
    );

    context.read<TravelPlanProvider>().addPlan(newPlan);

    Navigator.pop(context, newPlan);
  }
}
