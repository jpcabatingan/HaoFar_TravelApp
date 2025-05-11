// screens/profile.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/user_provider.dart';
import 'edit_profile_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (userProvider.isLoading || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
                              : NetworkImage(
                                    user.profilePicture ??
                                        'https://picsum.photos/200',
                                  )
                                  as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFA3B565),
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
            _visibilityToggle(userProvider),
            const SizedBox(height: 12),
            Text(
              user.username,
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${user.firstName} ${user.lastName}',
              style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.bio ?? 'No bio yet.',
                style: GoogleFonts.lexend(),
              ),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Email'),
            _sectionText(user.email),
            const SizedBox(height: 12),
            _sectionLabel('Phone Number'),
            _sectionText(user.phoneNumber ?? 'Not set'),
            const SizedBox(height: 20),
            _sectionLabel('Interests'),
            const SizedBox(height: 6),
            _chipWrap(user.interests, const Color(0xFFFCDD9D)),
            const SizedBox(height: 20),
            _sectionLabel('Preferred Travel Styles'),
            const SizedBox(height: 6),
            _chipWrap(user.travelStyles, const Color(0xFFFCDD9D)),
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
                    backgroundColor: const Color(0xFFA3B565),
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
                  child: Text('Edit Profile', style: GoogleFonts.lexend()),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().signOut();
                    Navigator.pushReplacementNamed(context, '/');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibilityToggle(UserProvider provider) {
    final user = provider.user!;

    return GestureDetector(
      onTap: () async {
        await provider.updateProfile({
          'isProfilePublic': !user.isProfilePublic,
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color:
              user.isProfilePublic
                  ? const Color(0xFFF1642E).withOpacity(0.2)
                  : Colors.grey.shade300,
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              user.isProfilePublic ? Icons.visibility : Icons.visibility_off,
              size: 18,
              color:
                  user.isProfilePublic
                      ? const Color(0xFFF1642E)
                      : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              user.isProfilePublic ? 'Public Profile' : 'Private Profile',
              style: GoogleFonts.lexend(
                fontSize: 12,
                color:
                    user.isProfilePublic
                        ? const Color(0xFFF1642E)
                        : Colors.grey.shade600,
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // TODO: Implement Firebase Storage upload and updateProfilePicture
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
