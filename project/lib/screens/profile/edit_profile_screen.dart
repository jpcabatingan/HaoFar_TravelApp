import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // TODO: replace with data from backend
  final TextEditingController nameController = TextEditingController(text: 'John Doe');
  final TextEditingController phoneController = TextEditingController(text: '+639123456789');
  final TextEditingController bioController = TextEditingController(
    text:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
  );

  List<String> allTags = [
    'Solo Travel',
    'Backpacking',
    'City Tours',
    'Adventure',
    'Coding',
    'Luxury',
    'Beaches',
    'Photography',
    'Museums',
  ];

  List<String> selectedInterests = ['City Tours', 'Adventure'];
  List<String> selectedTravelStyles = ['Solo Travel'];

  void _toggleSelection(String tag, List<String> list) {
    setState(() {
      list.contains(tag) ? list.remove(tag) : list.add(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = const Color.fromARGB(255, 163, 181, 101);
    final Color chipColor = const Color(0xFFFCDD9D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Edit Profile", style: GoogleFonts.lexend(color: Colors.black)),
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTextField(label: 'Full Name', controller: nameController),
              const SizedBox(height: 16),
              _buildTextField(label: 'Phone Number', controller: phoneController),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Bio',
                controller: bioController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _sectionLabel('Interests'),
              _selectableChips(allTags, selectedInterests, chipColor),
              const SizedBox(height: 20),
              _sectionLabel('Preferred Travel Styles'),
              _selectableChips(allTags, selectedTravelStyles, chipColor),
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
                    elevation: 2,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: save data to backend
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save Changes', style: GoogleFonts.lexend()),
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

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _selectableChips(List<String> tags, List<String> selected, Color bgColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tags.map((tag) {
        final isSelected = selected.contains(tag);
        return FilterChip(
          label: Text(tag, style: GoogleFonts.lexend(fontSize: 10)),
          selected: isSelected,
          backgroundColor: bgColor,
          selectedColor: const Color(0xFFF1642E),
          onSelected: (_) => _toggleSelection(tag, selected),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
