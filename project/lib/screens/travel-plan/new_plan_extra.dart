// Additional Information for created plans
// user can add optional additional information about their travel plan, including itinerary.
// Itinerary days are now added by picking a specific date within the plan's range.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/app/routes.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NewPlanExtra extends StatefulWidget {
  const NewPlanExtra({super.key});

  @override
  State<NewPlanExtra> createState() => _NewPlanExtraState();
}

class _NewPlanExtraState extends State<NewPlanExtra> {
  final Color _btnColor = const Color.fromARGB(255, 163, 181, 101);
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _flightController;
  late TextEditingController _accommodationController;
  late TextEditingController _notesController;

  List<Map<String, dynamic>> _editableChecklist = [];
  List<Map<String, dynamic>> _editableItinerary = [];

  final _checklistItemController = TextEditingController();
  final _itineraryActivityDetailController = TextEditingController();

  bool _isInitialized = false;
  TravelPlan?
  _draftPlanInstance; // To store the draft plan's start and end dates

  @override
  void initState() {
    super.initState();
    _flightController = TextEditingController();
    _accommodationController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final provider = context.read<TravelPlanProvider>();
      _draftPlanInstance = provider.draftPlan; // Store for date range access

      if (_draftPlanInstance != null) {
        _flightController.text =
            _draftPlanInstance!.additionalInfo['flightDetails'] as String? ??
            '';
        _accommodationController.text =
            _draftPlanInstance!.additionalInfo['accommodation'] as String? ??
            '';

        final notesListDynamic = _draftPlanInstance!.additionalInfo['notes'];
        if (notesListDynamic is List) {
          _notesController.text = notesListDynamic.whereType<String>().join(
            '\n',
          );
        } else {
          _notesController.text = '';
        }

        final dynamic rawChecklist =
            _draftPlanInstance!.additionalInfo['checklist'];
        if (rawChecklist is List) {
          _editableChecklist =
              rawChecklist
                  .map<Map<String, dynamic>>((item) {
                    if (item is Map) {
                      return Map<String, dynamic>.from(item);
                    }
                    return {'title': 'Invalid item format', 'done': false};
                  })
                  .where((item) => item['title'] != 'Invalid item format')
                  .toList();
        } else {
          _editableChecklist = [];
        }

        final List<Map<String, dynamic>> itineraryFromDraft =
            _draftPlanInstance!.itinerary;
        _editableItinerary =
            itineraryFromDraft.map((dayMap) {
              List<dynamic> activitiesDynamic =
                  dayMap['activities'] as List<dynamic>? ?? [];
              List<Map<String, dynamic>> typedActivities =
                  activitiesDynamic
                      .map<Map<String, dynamic>>((activityMap) {
                        if (activityMap is Map) {
                          return Map<String, dynamic>.from(activityMap);
                        }
                        return {
                          'time': 'Error',
                          'activity': 'Invalid activity format',
                        };
                      })
                      .where(
                        (activity) =>
                            activity['activity'] != 'Invalid activity format',
                      )
                      .toList();

              return Map<String, dynamic>.from({
                'day': dayMap['day'],
                'date':
                    dayMap['date'] != null
                        ? (dayMap['date'] is Timestamp
                            ? (dayMap['date'] as Timestamp)
                                .toDate()
                                .toIso8601String()
                            : dayMap['date'].toString())
                        : null,
                'activities': typedActivities,
              });
            }).toList();
        _editableItinerary.sort((a, b) {
          final dayA = a['day'] as int?;
          final dayB = b['day'] as int?;
          if (dayA != null && dayB != null) return dayA.compareTo(dayB);
          return 0;
        });
      } else {
        print(
          "NewPlanExtra: Draft plan is null. This might indicate an issue in navigation flow.",
        );
      }
      _isInitialized = true;
    }
  }

  void _addChecklistItem() {
    if (_checklistItemController.text.trim().isNotEmpty && mounted) {
      setState(() {
        _editableChecklist.add({
          'title': _checklistItemController.text.trim(),
          'done': false,
        });
        _checklistItemController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    if (mounted && index >= 0 && index < _editableChecklist.length) {
      setState(() => _editableChecklist.removeAt(index));
    }
  }

  void _toggleChecklistItemStatus(int index) {
    if (mounted && index >= 0 && index < _editableChecklist.length) {
      setState(() {
        bool currentStatus =
            _editableChecklist[index]['done'] as bool? ?? false;
        _editableChecklist[index]['done'] = !currentStatus;
      });
    }
  }

  void _addItineraryDay() async {
    if (_draftPlanInstance?.startDate == null ||
        _draftPlanInstance?.endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Plan start and end dates are not set. Go back to the previous step.',
          ),
        ),
      );
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _draftPlanInstance!.startDate,
      firstDate: _draftPlanInstance!.startDate,
      lastDate: _draftPlanInstance!.endDate,
      helpText: 'Select a Date for Itinerary Day',
    );

    if (pickedDate != null && mounted) {
      final int dayNumber =
          pickedDate.difference(_draftPlanInstance!.startDate).inDays + 1;
      bool dayExists = _editableItinerary.any((day) => day['day'] == dayNumber);

      if (dayExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Itinerary for Day $dayNumber (${DateFormat.yMMMd().format(pickedDate)}) already exists.',
            ),
          ),
        );
      } else {
        setState(() {
          _editableItinerary.add({
            'day': dayNumber,
            'date': pickedDate.toIso8601String(),
            'activities': <Map<String, dynamic>>[],
          });
          _editableItinerary.sort((a, b) {
            final dayA = a['day'] as int?;
            final dayB = b['day'] as int?;
            if (dayA != null && dayB != null) return dayA.compareTo(dayB);
            return 0;
          });
        });
      }
    }
  }

  void _removeItineraryDay(int dayIndex) {
    if (mounted && dayIndex >= 0 && dayIndex < _editableItinerary.length) {
      setState(() {
        _editableItinerary.removeAt(dayIndex);
      });
    }
  }

  void _addItineraryActivity(int dayIndex) async {
    if (dayIndex < 0 || dayIndex >= _editableItinerary.length) return;

    final dayData = _editableItinerary[dayIndex];
    final dayNumber = dayData['day'];
    final String dayDateString =
        dayData['date'] != null
            ? DateFormat.yMMMd().format(
              DateTime.parse(dayData['date'] as String),
            )
            : "Day $dayNumber";

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null || !mounted) return;

    _itineraryActivityDetailController.clear();

    final String? activityText = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Activity for $dayDateString at ${pickedTime.format(context)}',
          ),
          content: TextField(
            controller: _itineraryActivityDetailController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Activity description'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (_itineraryActivityDetailController.text.trim().isNotEmpty) {
                  Navigator.of(
                    context,
                  ).pop(_itineraryActivityDetailController.text.trim());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Activity description cannot be empty.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (activityText != null && activityText.isNotEmpty && mounted) {
      setState(() {
        final dayActivities = _editableItinerary[dayIndex]['activities'];
        if (dayActivities is List<Map<String, dynamic>>) {
          dayActivities.add({
            'time': pickedTime.format(context),
            'activity': activityText,
          });
        } else {
          _editableItinerary[dayIndex]['activities'] = <Map<String, dynamic>>[
            {'time': pickedTime.format(context), 'activity': activityText},
          ];
        }
      });
    }
  }

  void _removeItineraryActivity(int dayIndex, int activityIndex) {
    if (mounted && dayIndex >= 0 && dayIndex < _editableItinerary.length) {
      final activities = _editableItinerary[dayIndex]['activities'];
      if (activities is List &&
          activityIndex >= 0 &&
          activityIndex < activities.length) {
        setState(() {
          (activities as List<Map<String, dynamic>>).removeAt(activityIndex);
        });
      }
    }
  }

  void _savePlan(BuildContext context) async {
    final provider = context.read<TravelPlanProvider>();
    final draftPlan =
        provider
            .draftPlan; // Use the initially stored draftPlan for its core details

    if (draftPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No draft plan found to save.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> currentAdditionalInfo =
        Map<String, dynamic>.from(draftPlan.additionalInfo);

    final updatedAdditionalInfo = {
      ...currentAdditionalInfo,
      'flightDetails': _flightController.text.trim(),
      'accommodation': _accommodationController.text.trim(),
      'notes':
          _notesController.text
              .trim()
              .split('\n')
              .where((n) => n.isNotEmpty)
              .toList(),
      'checklist': List<Map<String, dynamic>>.from(_editableChecklist),
    };

    final TravelPlan finalPlan = draftPlan.copyWith(
      // copyWith uses the original draft plan's core details
      additionalInfo: updatedAdditionalInfo,
      itinerary: List<Map<String, dynamic>>.from(
        _editableItinerary.map(
          (day) => {
            'day': day['day'],
            'date': day['date'], // Save the date
            'activities': List<Map<String, dynamic>>.from(
              (day['activities'] as List).map(
                (act) => Map<String, dynamic>.from(act as Map),
              ),
            ),
          },
        ),
      ),
    );

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saving plan...')));
      await provider.createPlan(finalPlan);
      provider.clearDraftPlan();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.travelList,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _flightController.dispose();
    _accommodationController.dispose();
    _notesController.dispose();
    _checklistItemController.dispose();
    _itineraryActivityDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _draftPlanInstance is initialized in didChangeDependencies
    if (_draftPlanInstance == null && !_isInitialized) {
      // This indicates an issue if reached after initialization attempt
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(
          child: Text(
            "Draft plan data is unavailable. Please go back and start a new plan.",
          ),
        ),
      );
    }
    // If _isInitialized is true but _draftPlanInstance is still null, it means it was null from provider.
    if (_isInitialized && _draftPlanInstance == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(
          child: Text("No draft plan data. Please create a plan first."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EEF8),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Add Extra Details',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            tooltip: 'Save Plan',
            onPressed: () => _savePlan(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Additional Information'),
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
                  labelText: 'Accommodation Details',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (one per line)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              _buildSectionTitle('Checklist'),
              _buildChecklistSection(),
              const SizedBox(height: 30),

              _buildSectionTitle('Itinerary'),
              _buildItinerarySection(),
              const SizedBox(height: 40),

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
                  child: const Text("SAVE PLAN"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_editableChecklist.isEmpty) const Text("No checklist items yet."),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _editableChecklist.length,
          itemBuilder: (context, index) {
            final item = _editableChecklist[index];
            return CheckboxListTile(
              title: Text(
                item['title']?.toString() ?? 'Untitled',
                style: TextStyle(
                  decoration:
                      (item['done'] ?? false)
                          ? TextDecoration.lineThrough
                          : null,
                  color: (item['done'] ?? false) ? Colors.grey : Colors.black,
                ),
              ),
              value: item['done'] as bool? ?? false,
              onChanged: (value) => _toggleChecklistItemStatus(index),
              secondary: IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                onPressed: () => _removeChecklistItem(index),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      ],
    );
  }

  Widget _buildItinerarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("Add Itinerary for a Specific Date"),
          onPressed: _addItineraryDay,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 10),
        if (_editableItinerary.isEmpty)
          const Text("No itinerary days added yet."),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _editableItinerary.length,
          itemBuilder: (context, dayIndex) {
            final dayData = _editableItinerary[dayIndex];
            final dayNumber = dayData['day'] as int? ?? (dayIndex + 1);
            final String dayDateStr =
                dayData['date'] != null
                    ? DateFormat.yMMMd().format(
                      DateTime.parse(dayData['date'] as String),
                    )
                    : "Day $dayNumber";
            final activitiesDynamic =
                dayData['activities'] as List<dynamic>? ?? [];
            final activities =
                activitiesDynamic.whereType<Map<String, dynamic>>().toList();

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Day $dayNumber ($dayDateStr)",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: "Remove Day $dayNumber",
                          onPressed: () => _removeItineraryDay(dayIndex),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (activities.isEmpty)
                      const Text("No activities for this day yet."),
                    ...activities.asMap().entries.map((entry) {
                      final activityIndex = entry.key;
                      final activityData = entry.value;
                      return ListTile(
                        leading: const Icon(Icons.schedule, size: 20),
                        title: Text(
                          "${activityData['time']} - ${activityData['activity']}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          tooltip: "Remove activity",
                          onPressed:
                              () => _removeItineraryActivity(
                                dayIndex,
                                activityIndex,
                              ),
                        ),
                        dense: true,
                      );
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add_task, size: 18),
                        label: const Text("Add Activity"),
                        onPressed: () => _addItineraryActivity(dayIndex),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
