import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // TODO: replace with dynamic values from the backend
  String username = 'johndoe123'; // <-- hardcoded
  String fullName = 'John Doe'; // <-- hardcoded
  String email = 'john.doe@example.com'; // <-- hardcoded
  String phoneNumber = '+639123456789'; // <-- hardcoded
  String bio =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit...'; // <-- hardcoded

  List<String> interests = [
    // <-- hardcoded
    'Solo Travel',
    'Backpacking',
    'City Tours',
    'Adventure',
    'Coding',
  ];

  List<String> travelStyles = [
    // <-- hardcoded
    'Solo Travel',
    'Backpacking',
    'City Tours',
    'Adventure',
  ];

  bool isPublic = true; // TODO: fetch actual profile visibility from backend

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // TODO: upload picked image to firebase Storage and save its URL
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Choose from Gallery', style: GoogleFonts.lexend()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Take a Photo', style: GoogleFonts.lexend()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = const Color.fromARGB(255, 163, 181, 101);
    final Color chipColor = const Color(0xFFFCDD9D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: GoogleFonts.lexend(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _showImageSourceActionSheet,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          _imageFile != null
                              ? FileImage(_imageFile!)
                              : const AssetImage(
                                    'assets/avatar_placeholder.png',
                                  )
                                  as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: buttonColor,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _visibilityToggle(),
            const SizedBox(height: 12),
            Text(
              username, // <-- from variable
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fullName, // <-- from variable
              style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                bio,
                style: GoogleFonts.lexend(),
              ), // <-- from variable
            ),
            const SizedBox(height: 20),
            _sectionLabel('Email'),
            _sectionText(email), // <-- from variable
            const SizedBox(height: 12),
            _sectionLabel('Phone Number'),
            _sectionText(phoneNumber), // <-- from variable
            const SizedBox(height: 20),
            _sectionLabel('Interests'),
            const SizedBox(height: 6),
            _chipWrap(interests, chipColor),
            const SizedBox(height: 20),
            _sectionLabel('Preferred Travel Styles'),
            const SizedBox(height: 6),
            _chipWrap(travelStyles, chipColor),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
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
                  child: Text('Edit Profile', style: GoogleFonts.lexend()),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _visibilityToggle() {
    final Color activeColor = const Color(0xFFF1642E);
    final Color inactiveColor = const Color(0xFFFCDD9D);

    return GestureDetector(
      onTap: () {
        setState(() {
          isPublic = !isPublic;
          // TODO: save new visibility state to backend
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isPublic ? inactiveColor : Colors.grey.shade300,
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPublic ? Icons.visibility : Icons.visibility_off,
              size: 18,
              color: isPublic ? activeColor : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              isPublic ? 'Public Profile' : 'Private Profile',
              style: GoogleFonts.lexend(
                fontSize: 12,
                color: isPublic ? activeColor : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.swap_horiz, size: 18, color: Colors.black54),
          ],
        ),
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

  Widget _sectionText(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: GoogleFonts.lexend(fontSize: 13)),
  );

  Widget _chipWrap(List<String> items, Color bgColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children:
            items
                .map(
                  (label) => Chip(
                    label: Text(label, style: GoogleFonts.lexend(fontSize: 10)),
                    backgroundColor: bgColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
