import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/api/users_api.dart';
import 'package:project/models/user.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final UserApi _userApi = UserApi();
  bool _loading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await _userApi.getUser(widget.userId);
    setState(() {
      _user = u;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _user == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final u = _user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${u.username}’s Profile',
            style: GoogleFonts.roboto(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(u.profilePicture ?? ''),
          ),
          const SizedBox(height: 16),
          Text(u.username,
              style:
                  GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20)),
          Text('${u.firstName} ${u.lastName}',
              style: GoogleFonts.roboto(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 16),
          Text(u.bio?.isEmpty ?? true ? 'No bio yet.' : u.bio!,
              style: GoogleFonts.roboto()),
          const SizedBox(height: 24),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Interests',
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: u.interests
                .map((i) => Chip(
                      label: Text(i, style: GoogleFonts.roboto(fontSize: 10)),
                      backgroundColor: const Color(0xFFFCDD9D),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Travel Styles',
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: u.travelStyles
                .map((s) => Chip(
                      label: Text(s, style: GoogleFonts.roboto(fontSize: 10)),
                      backgroundColor: const Color(0xFFFCDD9D),
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // TODO: implement “add friend”
            },
            child: Text('Add Friend', style: GoogleFonts.roboto()),
          ),
        ]),
      ),
    );
  }
}
