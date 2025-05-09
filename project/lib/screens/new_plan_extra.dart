import 'package:flutter/material.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:provider/provider.dart';

class NewPlanExtra extends StatefulWidget {
  const NewPlanExtra({super.key});

  @override
  State<NewPlanExtra> createState() => _NewPlanExtraState();
}

class _NewPlanExtraState extends State<NewPlanExtra> {
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);

  late TextEditingController _flightController;
  late TextEditingController _accommodationController;
  late TextEditingController _notesController;
  late TextEditingController _checklistItemController;

  late Map<String, dynamic> _additionalInfo = {};
  late List<String> _checklist = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<TravelPlanProvider>();
    final draftPlan = provider.draftPlan;

    if (draftPlan == null) return;

    // Initialize controllers with draft plan data
    _flightController = TextEditingController(
      text: draftPlan.additionalInfo['flightDetails'] ?? '',
    );
    _accommodationController = TextEditingController(
      text: draftPlan.additionalInfo['accommodation'] ?? '',
    );
    _notesController = TextEditingController(
      text:
          (draftPlan.additionalInfo['notes'] as List<String>?)?.join('\n') ??
          '',
    );
    _checklistItemController = TextEditingController();

    // Initialize checklist from draft plan
    _checklist = List<String>.from(draftPlan.additionalInfo['checklist'] ?? []);
    _additionalInfo = Map<String, dynamic>.from(draftPlan.additionalInfo);
  }

  void _addChecklistItem() {
    final text = _checklistItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _checklist.add(text);
        _checklistItemController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklist.removeAt(index);
    });
  }

  void _updateAdditionalInfo(String key, String value) {
    setState(() {
      if (value.isEmpty) {
        _additionalInfo.remove(key);
      } else {
        _additionalInfo[key] = value;
      }
    });
  }

  void _savePlan(BuildContext context) async {
    final provider = context.read<TravelPlanProvider>();
    final draftPlan = provider.draftPlan;

    if (draftPlan == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No draft plan found')));
      return;
    }

    // Update additional info with current form values
    final updatedInfo = {
      ..._additionalInfo,
      'flightDetails': _flightController.text.trim(),
      'accommodation': _accommodationController.text.trim(),
      'notes':
          _notesController.text
              .trim()
              .split('\n')
              .where((n) => n.isNotEmpty)
              .toList(),
      'checklist': _checklist,
    };

    final updatedPlan = draftPlan.copyWith(additionalInfo: updatedInfo);

    try {
      await provider.createPlan(updatedPlan);
      provider.clearDraftPlan();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/travel-list',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _flightController.dispose();
    _accommodationController.dispose();
    _notesController.dispose();
    _checklistItemController.dispose();
    super.dispose();
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
              'Add More Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _flightController,
              onChanged:
                  (value) => _updateAdditionalInfo('flightDetails', value),
              decoration: const InputDecoration(
                labelText: 'Flight Details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _accommodationController,
              onChanged:
                  (value) => _updateAdditionalInfo('accommodation', value),
              decoration: const InputDecoration(
                labelText: 'Accommodation Details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              onChanged: (value) => _updateAdditionalInfo('notes', value),
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
                    controller: _checklistItemController,
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
            ..._checklist.asMap().entries.map((entry) {
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
            if (_checklist.isEmpty) const Text('No checklist items added yet.'),
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
                child: const Text("Save Plan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
