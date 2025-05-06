import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
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
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : const AssetImage('assets/avatar_placeholder.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color.fromARGB(255, 163, 181, 101),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('johndoe123',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            const Text('John Doe', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud ',
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('john.doe@example.com'),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('+639123456789'),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Interests', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _chip('Solo Travel'),
                  _chip('Backpacking'),
                  _chip('City Tours'),
                  _chip('Adventure'),
                  _chip('Coding'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Preferred Travel Styles', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _chip('Solo Travel'),
                  _chip('Backpacking'),
                  _chip('City Tours'),
                  _chip('Adventure'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 163, 181, 101),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 8)),
      backgroundColor: const Color(0xFFFCDD9D),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
