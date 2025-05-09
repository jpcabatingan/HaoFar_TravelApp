import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:provider/provider.dart';

class EditPlan extends StatefulWidget {
  const EditPlan({super.key});

  @override
  State<EditPlan> createState() => _EditPlanState();
}

class _EditPlanState extends State<EditPlan> {
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  late TextEditingController _flightController;
  late TextEditingController _accommodationController;
  late TextEditingController _notesController;
  late TextEditingController _checklistController;

  List<String> checklist = [];

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

  @override
  void initState() {
    super.initState();
    final plan = context.read<TravelPlanProvider>().selectedPlan;
    if (plan == null) return;

    _titleController.text = plan.name;
    _locationController.text = plan.location;
    _startDate = plan.startDate;
    _endDate = plan.endDate;

    _flightController = TextEditingController(text: plan.flightDetails);
    _accommodationController = TextEditingController(text: plan.accommodation);
    _notesController = TextEditingController(text: plan.notes.join('\n'));
    _checklistController = TextEditingController();

    checklist = plan.checklist;
  }

  void _addChecklistItem() {
    if (_checklistController.text.isNotEmpty) {
      setState(() {
        checklist.add(_checklistController.text.trim());
        _checklistController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    setState(() => checklist.removeAt(index));
  }

  void _saveInfo() {
    final provider = context.read<TravelPlanProvider>();
    final plan = provider.selectedPlan;

    if (plan == null || _startDate == null || _endDate == null) return;

    final updatedPlan = TravelPlan(
      planId: plan.planId,
      createdBy: plan.createdBy,
      name: _titleController.text,
      startDate: _startDate!,
      endDate: _endDate!,
      location: _locationController.text,
      additionalInfo: {
        'flightDetails': _flightController.text,
        'accommodation': _accommodationController.text,
        'notes':
            _notesController.text
                .split('\n')
                .where((n) => n.isNotEmpty)
                .toList(),
        'checklist': checklist,
      },
      itinerary: plan.itinerary,
      sharedWith: plan.sharedWith,
      qrCodeData: plan.qrCodeData,
    );

    provider.updatePlan(updatedPlan);
    Navigator.pop(context);
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
              'Edit Plan',
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
              decoration: const InputDecoration(
                labelText: 'Location',
                suffixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _flightController,
              decoration: const InputDecoration(
                labelText: 'Flight Details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _accommodationController,
              decoration: const InputDecoration(
                labelText: 'Accommodation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Notes (one per line)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checklistController,
                    decoration: const InputDecoration(
                      labelText: 'Add Checklist Item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addChecklistItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...checklist.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                title: Text(item),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  onPressed: () => _removeChecklistItem(index),
                ),
              );
            }).toList(),
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
                onPressed: _saveInfo,
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
