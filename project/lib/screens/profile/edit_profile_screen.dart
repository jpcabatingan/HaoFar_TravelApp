import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:project/providers/user_provider.dart';
import 'package:project/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> interestTags = [
    "Local Food",
    "Fancy Cuisine",
    "Locals",
    "Rich History",
    "Beaches",
    "Mountains",
    "Malls",
    "Festivals",
    "Solo Travel",
    "Adventure",
    "Luxury",
    "Photography",
    "Museums",
  ];

  List<String> travelStyleTags = [
    "Solo",
    "Group",
    "Backpacking",
    "Long-Term",
    "Short-Term",
  ];

  List<String> selectedInterests = [];
  List<String> selectedTravelStyles = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    final userProvider = context.read<UserProvider>();
    final userModel = userProvider.user;

    if (userModel != null) {
      // Initialize controllers
      nameController = TextEditingController(
        text: '${userModel.firstName} ${userModel.lastName}',
      );
      phoneController = TextEditingController(
        text: userModel.phoneNumber ?? '',
      );
      bioController = TextEditingController(text: userModel.bio ?? '');

      selectedInterests = List.from(userModel.interests);
      selectedTravelStyles = List.from(userModel.travelStyles);
    } else {
      // Fallback to empty state
      nameController = TextEditingController();
      phoneController = TextEditingController();
      bioController = TextEditingController();
    }
  }

  void _toggleSelection(String tag, List<String> currentList) {
    setState(() {
      final isSelected = currentList.contains(tag);
      isSelected ? currentList.remove(tag) : currentList.add(tag);
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    final userModel = userProvider.user;
    if (userModel == null) return;

    setState(() => _isLoading = true);

    try {
      // Parse full name
      final fullName = nameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join('') : '';

      // Build update data
      final updateData = <String, dynamic>{};

      if (firstName != userModel.firstName) {
        updateData['firstName'] = firstName;
      }
      if (lastName != userModel.lastName) {
        updateData['lastName'] = lastName;
      }
      final phone = phoneController.text.trim();
      if (phone != userModel.phoneNumber) {
        updateData['phoneNumber'] = phone;
      }
      final bio = bioController.text.trim();
      if (bio != userModel.bio) {
        updateData['bio'] = bio;
      }
      if (!listEquals(selectedInterests, userModel.interests)) {
        updateData['interests'] = selectedInterests;
      }
      if (!listEquals(selectedTravelStyles, userModel.travelStyles)) {
        updateData['travelStyles'] = selectedTravelStyles;
      }

      if (updateData.isEmpty) {
        // No changes made
        Navigator.pop(context);
        return;
      }

      // Save to backend
      await userProvider.updateProfile(updateData);
      Navigator.pop(context);
    } catch (e) {
      // Show error
      final snackBar = SnackBar(
        content: Text('Failed to save changes: $e'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userModel = userProvider.user;

    if (userModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final buttonColor = const Color.fromARGB(255, 163, 181, 101);
    final chipColor = const Color(0xFFFCDD9D);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.lexend(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTextField(label: 'Full Name', controller: nameController),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Phone Number',
                controller: phoneController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Bio',
                controller: bioController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _sectionLabel('Interests'),
              _selectableChips(interestTags, selectedInterests, chipColor),
              const SizedBox(height: 20),
              _sectionLabel('Preferred Travel Styles'),
              _selectableChips(
                travelStyleTags,
                selectedTravelStyles,
                chipColor,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.black26, width: 1),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveChanges,
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
                          : Text('Save Changes', style: GoogleFonts.lexend()),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      style: GoogleFonts.lexend(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _sectionLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );

  Widget _selectableChips(
    List<String> tags,
    List<String> currentList,
    Color bgColor,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children:
          tags.map((tag) {
            final isSelected = currentList.contains(tag);
            return FilterChip(
              label: Text(tag, style: GoogleFonts.lexend(fontSize: 10)),
              selected: isSelected,
              backgroundColor: bgColor,
              selectedColor: const Color(0xFFF1642E),
              onSelected: (bool selected) {
                _toggleSelection(tag, currentList);
              },
              showCheckmark: false,
            );
          }).toList(),
    );
  }
}
