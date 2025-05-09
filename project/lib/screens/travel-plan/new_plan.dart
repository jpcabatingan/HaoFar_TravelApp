import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';

class NewPlan extends StatefulWidget {
  const NewPlan({super.key});

  @override
  State<NewPlan> createState() => _NewPlanState();
}

class _NewPlanState extends State<NewPlan> {
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  Map<String, dynamic> _additionalInfo = {};

  void _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _pickEndDate() async {
    if (_startDate == null) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _savePlan(BuildContext context) {
    final provider = Provider.of<TravelPlanProvider>(context, listen: false);
    final user = provider.currentUser;

    if (_titleController.text.isEmpty ||
        _startDate == null ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final newPlan = TravelPlan(
      planId: FirebaseFirestore.instance.collection('travelPlans').doc().id,
      createdBy: user?.uid ?? '',
      name: _titleController.text,
      startDate: _startDate!,
      endDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      location: _locationController.text,
      additionalInfo: _additionalInfo,
      itinerary: [],
      sharedWith: [],
      qrCodeData: null,
    );

    provider.createPlan(newPlan);

    Navigator.pushReplacementNamed(context, '/homepage');
  }

  void _navigateToExtraInfo(BuildContext context) {
    final provider = Provider.of<TravelPlanProvider>(context, listen: false);

    if (_titleController.text.isEmpty ||
        _startDate == null ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final draftPlan = TravelPlan(
      planId: '',
      createdBy: '',
      name: _titleController.text,
      startDate: _startDate!,
      endDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      location: _locationController.text,
      additionalInfo: _additionalInfo,
      itinerary: [],
      sharedWith: [],
      qrCodeData: null,
    );

    provider.setDraftPlan(draftPlan);
    Navigator.pushNamed(context, '/newPlanExtra');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EEF8),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'HaoFar Can I Go',
          style: TextStyle(color: Colors.black),
        ),
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
                _startDate == null
                    ? 'Select Start Date'
                    : DateFormat.yMMMMd().format(_startDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickStartDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(
                _endDate == null
                    ? 'Select End Date'
                    : DateFormat.yMMMMd().format(_endDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickEndDate,
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
                if (_titleController.text.isEmpty ||
                    _startDate == null ||
                    _locationController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                    ),
                  );
                  return;
                }

                final draftPlan = TravelPlan(
                  planId: '', // Empty for now; will be generated on save
                  createdBy: '', // Will be set by provider
                  name: _titleController.text,
                  startDate: _startDate!,
                  endDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
                  location: _locationController.text,
                  additionalInfo: _additionalInfo,
                  itinerary: [],
                  sharedWith: [],
                  qrCodeData: null,
                );

                context.read<TravelPlanProvider>().setDraftPlan(draftPlan);
                Navigator.pushNamed(context, '/newPlanExtra');
              },
              child: const Text(
                'Add more info',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
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
                onPressed: () => _savePlan(context),
                child: const Text("DONE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
