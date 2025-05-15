import 'package:flutter/material.dart';
import 'package:project/models/user.dart'; // Ensure this path is correct

class PrivateProfilePlaceholderScreen extends StatelessWidget {
  final UserModel
  user; // Pass the user model for potential use (e.g., username in AppBar)

  const PrivateProfilePlaceholderScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.username), // Display username in AppBar
        leading: IconButton(
          // Custom back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[200], // A light background for the appbar
      ),
      backgroundColor: Colors.grey[200], // Consistent background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for profile picture
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[400],
                backgroundImage:
                    user.profilePicture != null &&
                            user.profilePicture!.isNotEmpty
                        ? NetworkImage(user.profilePicture!)
                        : null, // Use actual image if available, otherwise default
                child:
                    user.profilePicture == null || user.profilePicture!.isEmpty
                        ? Icon(
                          Icons.no_photography_outlined, // Icon for no image
                          size: 50,
                          color: Colors.grey[700],
                        )
                        : null,
              ),
              const SizedBox(height: 20),
              Text(
                user.username, // Show username
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Icon(
                Icons.lock_outline, // Lock icon to signify privacy
                size: 60,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 20),
              const Text(
                'This Profile is Private',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Nothing to see here!',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back_ios_new),
                label: const Text('Go Back'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
