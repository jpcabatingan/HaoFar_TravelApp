import 'package:flutter/material.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/models/checklist_item.dart';

class NewPlanExtra extends StatefulWidget {
  const NewPlanExtra({super.key});

  @override
  State<NewPlanExtra> createState() => _NewPlanExtraState();
}

class _NewPlanExtraState extends State<NewPlanExtra> {
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);

  late TextEditingController _flightController;
  late TextEditingController _accommodationController;
  late TextEditingController _itineraryController;
  late TextEditingController _notesController;
  final TextEditingController _checklistItemController = TextEditingController();

  List<ChecklistItem> checklist = [];

  @override
  void initState() {
    super.initState();
    final plan = context.read<TravelPlanProvider>().currentlyAdding;

    _flightController = TextEditingController(text: plan.flight ?? '');
    _accommodationController = TextEditingController(text: plan.accommodation ?? '');
    _itineraryController = TextEditingController(text: plan.itinerary ?? '');
    _notesController = TextEditingController(text: plan.notes ?? '');
    checklist = List<ChecklistItem>.from(plan.checklist ?? []);
  }

  void _addChecklistItem() {
    if (_checklistItemController.text.isNotEmpty) {
      setState(() {
        checklist.add(ChecklistItem(text: _checklistItemController.text));
        _checklistItemController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    setState(() => checklist.removeAt(index));
  }

  void _saveInfo() {
    final provider = context.read<TravelPlanProvider>();
    final previous = provider.currentlyAdding;

    provider.currentlyAdding = TravelPlanModel(
      title: previous.title,
      date: previous.date,
      location: previous.location,
      category: previous.category,
      flight: _flightController.text,
      accommodation: _accommodationController.text,
      itinerary: _itineraryController.text,
      notes: _notesController.text,
      checklist: checklist,
    );

    provider.addPlan(provider.currentlyAdding);

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
        title: const Text('Traveler', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('Create new plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField('Flight Details', _flightController),
            const SizedBox(height: 20),
            _buildTextField('Accommodation Details', _accommodationController),
            const SizedBox(height: 20),
            _buildTextField('Itinerary', _itineraryController),
            const SizedBox(height: 20),
            _buildTextField('Other notes', _notesController),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checklistItemController,
                    decoration: const InputDecoration(labelText: 'Add item', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addChecklistItem,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...checklist.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return CheckboxListTile(
                title: Text(item.text),
                value: item.isChecked,
                onChanged: (val) {
                  setState(() => item.isChecked = val ?? false);
                },
                secondary: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => _removeChecklistItem(index),
                ),
              );
            }),
            const SizedBox(height: 20),
            _createDoneButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

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
          _saveInfo();
          print("Created new plan");
          Navigator.pushNamed(context, '/homepage');
        },
        child: const Text("DONE"),
      ),
    );
  }
}
