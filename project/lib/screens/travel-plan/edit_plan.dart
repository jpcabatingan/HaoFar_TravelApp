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
  String? planId;
  TravelPlan? plan;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize controllers only
    _flightController = TextEditingController();
    _accommodationController = TextEditingController();
    _notesController = TextEditingController();
    _checklistController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to access context here
    if (planId == null) {
      planId = ModalRoute.of(context)?.settings.arguments as String?;
      if (planId != null) {
        _fetchPlan();
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  Future<void> _fetchPlan() async {
    if (planId == null || !mounted) return;

    final provider = context.read<TravelPlanProvider>();
    try {
      final fetchedPlan = await provider.getPlanById(planId!);
      if (!mounted) return;

      if (fetchedPlan == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Plan not found')));
        Navigator.pop(context);
        return;
      }

      setState(() {
        plan = fetchedPlan;
        _titleController.text = plan!.name;
        _locationController.text = plan!.location;
        _startDate = plan!.startDate;
        _endDate = plan!.endDate;
        _flightController.text = plan!.flightDetails;
        _accommodationController.text = plan!.accommodation;
        _notesController.text = plan!.notes.join('\n');
        checklist = List.from(plan!.checklist);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching plan: $e')));
      Navigator.pop(context);
    }
  }

  void _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
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
    if (picked != null && mounted) {
      setState(() => _endDate = picked);
    }
  }

  void _addChecklistItem() {
    if (_checklistController.text.isNotEmpty && mounted) {
      setState(() {
        checklist.add(_checklistController.text.trim());
        _checklistController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    if (mounted) setState(() => checklist.removeAt(index));
  }

  void _saveInfo() async {
    if (plan == null || _startDate == null || _endDate == null) return;

    final provider = context.read<TravelPlanProvider>();
    final updatedPlan = TravelPlan(
      planId: plan!.planId,
      createdBy: plan!.createdBy,
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
      itinerary: plan!.itinerary,
      sharedWith: plan!.sharedWith,
      qrCodeData: plan!.qrCodeData,
    );

    try {
      await provider.updatePlan(updatedPlan);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update plan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (plan == null) {
      return const Scaffold(body: Center(child: Text('Plan not found')));
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: const Text(
          'Travel Plan Details',
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
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.grey),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
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
