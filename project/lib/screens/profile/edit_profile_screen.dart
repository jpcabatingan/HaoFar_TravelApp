import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:project/providers/user_provider.dart';
import 'package:project/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final List<String> interestTags = [
    "Local Food", "Fancy Cuisine", "Locals", "Rich History",
    "Beaches", "Mountains", "Malls", "Festivals",
  ];

  final List<String> travelStyleTags = [
    "Solo", "Group", "Backpacking", "Long-Term", "Short-Term",
  ];

  List<String> selectedInterests = [];
  List<String> selectedTravelStyles = [];

  @override
  void initState() {
    super.initState();
    final userModel = context.read<UserProvider>().user;
    if (userModel != null) {
      firstNameController = TextEditingController(text: userModel.firstName);
      lastNameController = TextEditingController(text: userModel.lastName);
      phoneController = TextEditingController(text: userModel.phoneNumber ?? '');
      bioController = TextEditingController(text: userModel.bio ?? '');
      selectedInterests = List.from(userModel.interests);
      selectedTravelStyles = List.from(userModel.travelStyles);
    } else {
      firstNameController = TextEditingController();
      lastNameController = TextEditingController();
      phoneController = TextEditingController();
      bioController = TextEditingController();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _toggleSelection(String tag, List<String> list) {
    setState(() {
      if (list.contains(tag)) list.remove(tag);
      else list.add(tag);
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    final userModel = context.read<UserProvider>().user;
    if (userModel == null) return;

    setState(() => _isLoading = true);
    try {
      final updateData = <String, dynamic>{};
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      if (firstName != userModel.firstName) {
        updateData['firstName'] = firstName;
      }
      if (lastName != userModel.lastName) {
        updateData['lastName'] = lastName;
      }
      final phone = phoneController.text.trim();
      if (phone != (userModel.phoneNumber ?? '')) {
        updateData['phoneNumber'] = phone;
      }
      final bio = bioController.text.trim();
      if (bio != (userModel.bio ?? '')) {
        updateData['bio'] = bio;
      }
      if (!listEquals(selectedInterests, userModel.interests)) {
        updateData['interests'] = selectedInterests;
      }
      if (!listEquals(selectedTravelStyles, userModel.travelStyles)) {
        updateData['travelStyles'] = selectedTravelStyles;
      }

      if (updateData.isNotEmpty) {
        await context.read<UserProvider>().updateProfile(updateData);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: \$e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<UserProvider>().user;
    if (userModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final buttonColor = const Color.fromARGB(255, 163, 181, 101);
    const chipColor = Color(0xFFFCDD9D);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Edit Profile', style: GoogleFonts.roboto(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'First Name',
                        controller: firstNameController,
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Last Name',
                        controller: lastNameController,
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Phone Number',
                  controller: phoneController,
                  isRequired: false,
                  hintText: userModel.phoneNumber?.isEmpty ?? true ? 'Not Set' : null,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Bio',
                  controller: bioController,
                  maxLines: 3,
                  isRequired: false,
                  hintText: userModel.bio?.isEmpty ?? true ? 'No bio yet' : null,
                ),
                const SizedBox(height: 20),
                _sectionLabel('Interests'),
                _selectableChips(interestTags, selectedInterests, chipColor),
                const SizedBox(height: 20),
                _sectionLabel('Preferred Travel Styles'),
                _selectableChips(travelStyleTags, selectedTravelStyles, chipColor),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.black26, width: 1),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    onPressed: _isLoading ? null : _saveChanges,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Save Changes', style: GoogleFonts.roboto()),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool isRequired = true,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter $label';
              return null;
            }
          : null,
      style: GoogleFonts.roboto(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _sectionLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
      );

  Widget _selectableChips(List<String> tags, List<String> currentList, Color bgColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tags.map((tag) {
        final isSelected = currentList.contains(tag);
        return FilterChip(
          label: Text(tag, style: GoogleFonts.roboto(fontSize: 10)),
          selected: isSelected,
          backgroundColor: bgColor,
          selectedColor: const Color(0xFFF1642E),
          onSelected: (_) => _toggleSelection(tag, currentList),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
