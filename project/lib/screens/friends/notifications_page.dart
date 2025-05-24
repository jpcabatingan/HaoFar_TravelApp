import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/api/users_api.dart';
import 'package:project/models/friend_request.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/profile/view_profile_screen.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final UserApi _api = UserApi();
  List<FriendRequest> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final pending = await _api.getIncomingFriendRequests();
      final notes  = await _api.getFriendRequestNotifications();
      setState(() {
        _requests = [...pending, ...notes]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notifications: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildTile(FriendRequest fr) {
    final isPending = fr.status == 'pending' && !fr.isNotification;
    return FutureBuilder<UserModel>(
      future: _api.getUser(fr.fromUserId),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snap.data!;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user.profilePicture?.isNotEmpty == true
                  ? MemoryImage(base64Decode(user.profilePicture!))
                  : null,
              child: (user.profilePicture == null || user.profilePicture!.isEmpty)
                  ? Text(user.firstName[0].toUpperCase(),
                      style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold))
                  : null,
            ),
            title: Text(user.username,
                style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
            subtitle: Text(
              fr.isNotification
                  ? "Your request was accepted!"
                  : "sent you a friend request",
              style: GoogleFonts.roboto(color: Colors.grey[600]),
            ),
            trailing: isPending
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await _api.respondToFriendRequest(fr.requestId, true);
                          _loadNotifications();
                        },
                        child: const Text("Accept"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _api.respondToFriendRequest(fr.requestId, false);
                          _loadNotifications();
                        },
                        child: const Text("Decline", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                : fr.isNotification
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _api.deleteNotification(fr.requestId);
                          _loadNotifications();
                        },
                      )
                    : null,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PublicProfileScreen(userId: user.userId),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child:
                      Text("No notifications", style: GoogleFonts.roboto(color: Colors.grey)),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: _requests.length,
                    itemBuilder: (_, i) => _buildTile(_requests[i]),
                  ),
                ),
    );
  }
}
