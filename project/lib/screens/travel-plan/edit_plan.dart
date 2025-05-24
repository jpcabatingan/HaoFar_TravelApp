// Edit plan page
// user can edit existing plans here, including a detailed itinerary.
// Itinerary days are now added by picking a specific date within the plan's range.

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  late TextEditingController _flightController;
  late TextEditingController _accommodationController;
  late TextEditingController _notesController;

  List<Map<String, dynamic>> _editableChecklist = [];
  List<Map<String, dynamic>> _editableItinerary = [];

  String? _planId;
  TravelPlan? _originalPlan;
  bool _isLoading = true;
  String? _loadingError;

  final _checklistItemController = TextEditingController();
  final _itineraryActivityDetailController = TextEditingController();

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
    if (_planId == null) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is String) {
        _planId = arguments;
        _fetchPlan();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadingError = "Invalid plan ID provided.";
          });
        }
      }
    }
  }

  Future<void> _fetchPlan() async {
    if (_planId == null || !mounted) return;
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    final provider = context.read<TravelPlanProvider>();
    try {
      final fetchedPlan = await provider.getPlanById(_planId!);
      if (!mounted) return;

      if (fetchedPlan == null) {
        setState(() {
          _isLoading = false;
          _loadingError = 'Plan not found. It might have been deleted.';
        });
        return;
      }

      _originalPlan = fetchedPlan;

      _titleController.text = fetchedPlan.name;
      _locationController.text = fetchedPlan.location;
      _startDate = fetchedPlan.startDate;
      _endDate = fetchedPlan.endDate;
      _flightController.text = fetchedPlan.flightDetails;
      _accommodationController.text = fetchedPlan.accommodation;

      final notesListDynamic = fetchedPlan.additionalInfo['notes'];
      if (notesListDynamic is List) {
        _notesController.text = notesListDynamic.whereType<String>().join('\n');
      } else {
        _notesController.text = '';
      }

      final dynamic rawChecklist = fetchedPlan.additionalInfo['checklist'];
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

      final List<Map<String, dynamic>> itineraryFromGetter =
          fetchedPlan.itinerary;
      _editableItinerary =
          itineraryFromGetter.map((dayMap) {
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
                      : null, // Store date as ISO string
              'activities': typedActivities,
            });
          }).toList();
      _editableItinerary.sort((a, b) {
        final dayA = a['day'] as int?;
        final dayB = b['day'] as int?;
        if (dayA != null && dayB != null) return dayA.compareTo(dayB);
        return 0; // Should not happen if day is always present
      });

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingError = 'Error fetching plan details: $e';
      });
    }
  }

  void _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
        // When start date changes, existing itinerary day numbers might become invalid if they fall outside new range.
        // For simplicity, we are not auto-adjusting/removing them here. User needs to manage.
        // A more advanced implementation could validate/prompt.
      });
    }
  }

  void _pickEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date first.')),
      );
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() => _endDate = picked);
      // Similar to _pickStartDate, itinerary days might become invalid.
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
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set the plan start and end dates first.'),
        ),
      );
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate!,
      firstDate: _startDate!,
      lastDate: _endDate!,
      helpText: 'Select a Date for Itinerary Day',
    );

    if (pickedDate != null && mounted) {
      // Calculate day number relative to the start date of the plan
      final int dayNumber = pickedDate.difference(_startDate!).inDays + 1;

      // Check if a day with this dayNumber already exists
      bool dayExists = _editableItinerary.any((day) => day['day'] == dayNumber);

      if (dayExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Itinerary for Day $dayNumber (${DateFormat.yMMMd().format(pickedDate)}) already exists. You can add activities to it directly.',
            ),
          ),
        );
      } else {
        setState(() {
          _editableItinerary.add({
            'day': dayNumber,
            'date':
                pickedDate
                    .toIso8601String(), // Store the actual date as ISO string
            'activities': <Map<String, dynamic>>[],
          });
          _editableItinerary.sort((a, b) {
            // Sort by day number
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
          // Optional: Sort activities by time if needed
          // dayActivities.sort((a,b) => (a['time'] as String).compareTo(b['time'] as String));
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

  Future<void> _saveInfo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_originalPlan == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing essential plan data. Cannot save.'),
        ),
      );
      return;
    }

    final provider = context.read<TravelPlanProvider>();

    final updatedAdditionalInfo = {
      ..._originalPlan!.additionalInfo,
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

    final updatedPlan = _originalPlan!.copyWith(
      name: _titleController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      location: _locationController.text.trim(),
      additionalInfo: updatedAdditionalInfo,
      itinerary: List<Map<String, dynamic>>.from(
        _editableItinerary.map(
          (day) => {
            'day': day['day'],
            'date': day['date'], // Ensure date is saved
            'activities': List<Map<String, dynamic>>.from(
              (day['activities'] as List).map(
                (act) => Map<String, dynamic>.from(act as Map),
              ),
            ),
          },
        ),
      ),
    );

    setState(() => _isLoading = true);
    try {
      await provider.updatePlan(updatedPlan);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update plan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _flightController.dispose();
    _accommodationController.dispose();
    _notesController.dispose();
    _checklistItemController.dispose();
    _itineraryActivityDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _originalPlan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Plan...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadingError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _loadingError!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    if (_originalPlan == null && !_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Plan data could not be loaded or does not exist.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Edit Travel Plan',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            tooltip: 'Save Changes',
            onPressed: _isLoading ? null : _saveInfo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Plan Title*',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Title cannot be empty'
                            : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                  _startDate == null
                      ? 'Select Start Date*'
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
                      ? 'Select End Date*'
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
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location*',
                  suffixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Location cannot be empty'
                            : null,
              ),
              const SizedBox(height: 30),

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
                  labelText: 'Accommodation',
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
                  onPressed: _isLoading ? null : _saveInfo,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text("Save Changes"),
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
          label: const Text(
            "Add Itinerary for a Specific Date",
          ), // Updated button text
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
