import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/user_provider.dart';
import 'edit_profile_screen.dart';
import 'package:project/screens/friends/notifications_page.dart';

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 204, 235),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png', height: 50),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 204, 235),
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          TextButton.icon(
            onPressed: () async {
              try {
                await context.read<AuthProvider>().signOut();
                Navigator.pushReplacementNamed(context, '/');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: \$e')),
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: Text('Sign Out', style: GoogleFonts.roboto(color: Colors.red)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceActionSheet,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (user.profilePicture != null
                                ? MemoryImage(
                                    base64Decode(user.profilePicture!),
                                  )
                                : const NetworkImage(
                                    'https://freesvg.org/img/abstract-user-flat-4.png',
                                  )) as ImageProvider,
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFA3B565),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: _visibilityToggle(userProvider)),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "@${user.username}",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '${user.firstName} ${user.lastName}',
                  style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  (user.bio?.isEmpty ?? true) ? 'No bio yet.' : user.bio!,
                  style: GoogleFonts.roboto(),
                ),
              ),
              const SizedBox(height: 24),
              _sectionLabel('Email'),
              _sectionText(user.email),
              const SizedBox(height: 16),
              _sectionLabel('Phone Number'),
              _sectionText(
                (user.phoneNumber?.isEmpty ?? true) ? 'Not set' : user.phoneNumber!,
              ),
              const SizedBox(height: 24),
              _sectionLabel('Interests'),
              const SizedBox(height: 8),
              _chipWrap(user.interests, const Color(0xFFFCDD9D)),
              const SizedBox(height: 24),
              _sectionLabel('Preferred Travel Styles'),
              const SizedBox(height: 8),
              _chipWrap(user.travelStyles, const Color(0xFFFCDD9D)),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
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
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: _visibilityToggle(userProvider)),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "@${user.username}",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      '${user.firstName} ${user.lastName}',
                      style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (user.bio?.isEmpty ?? true) ? 'No bio yet.' : user.bio!,
                      style: GoogleFonts.roboto(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('Email'),
                  _sectionText(user.email),
                  const SizedBox(height: 16),
                  _sectionLabel('Phone Number'),
                  _sectionText(
                    (user.phoneNumber?.isEmpty ?? true)
                        ? 'Not set'
                        : user.phoneNumber!,
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('Interests'),
                  const SizedBox(height: 8),
                  _chipWrap(user.interests, const Color(0xFFFCDD9D)),
                  const SizedBox(height: 24),
                  _sectionLabel('Preferred Travel Styles'),
                  const SizedBox(height: 8),
                  _chipWrap(user.travelStyles, const Color(0xFFFCDD9D)),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
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
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text('Edit Profile', style: GoogleFonts.roboto()),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextButton.icon(
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
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: Text(
                          'Sign Out',
                          style: GoogleFonts.roboto(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: user.isProfilePublic
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
              color: user.isProfilePublic
                  ? const Color(0xFFF1642E)
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              user.isProfilePublic ? 'Public Profile' : 'Private Profile',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: user.isProfilePublic
                    ? const Color(0xFFF1642E)
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
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
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    setState(() => _imageFile = file);

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    try {
      await context.read<UserProvider>().updateProfilePicture(base64Image);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating picture: $e')),
      );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Gallery', style: GoogleFonts.roboto()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Camera', style: GoogleFonts.roboto()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      );

  Widget _sectionText(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: GoogleFonts.roboto(fontSize: 13)),
      );

  Widget _chipWrap(List<String> items, Color bgColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items
          .map(
            (label) => Chip(
              label: Text(label, style: GoogleFonts.roboto(fontSize: 10)),
              backgroundColor: bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
          .toList(),
    );
  }
}