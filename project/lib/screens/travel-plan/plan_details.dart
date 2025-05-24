// Plan Details
// user can view details of the plan and have the option to edit (only if creator) or delete (only if creator)
// Checklist items are now interactive on this screen.
// Sharing with friends now uses a selectable list of friends.
// AppBar removed, BackButton placed above title and styled. Title moved to left.

import 'dart:convert'; // For base64Decode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:project/app/routes.dart';
import 'package:project/models/user.dart';
import 'package:project/api/users_api.dart';
import 'package:project/providers/user_provider.dart';

class PlanDetails extends StatelessWidget {
  const PlanDetails({super.key});

  Future<void> _shareByUsernameDialog(
    BuildContext context,
    TravelPlan plan,
    TravelPlanProvider provider,
  ) async {
    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final String? currentUserId = userProvider.user?.userId;
    List<UserModel> friendsDetails = [];
    bool isLoadingFriends = true;
    String? selectedFriendUsername;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot load friends: User not logged in."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Future<List<UserModel>> fetchFriendsForDialog() async {
      final currentUserData = userProvider.user;
      if (currentUserData == null || currentUserData.friends.isEmpty) {
        return [];
      }

      List<UserModel> tempFriendsDetails = [];
      final UserApi userApi = UserApi();
      for (String friendId in currentUserData.friends) {
        try {
          if (friendId != plan.createdBy &&
              !plan.sharedWith.contains(friendId)) {
            UserModel friend = await userApi.getUser(friendId);
            if (friend.isProfilePublic) {
              tempFriendsDetails.add(friend);
            }
          }
        } catch (e) {
          print("Error fetching friend details for $friendId: $e");
        }
      }
      return tempFriendsDetails;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            if (isLoadingFriends) {
              fetchFriendsForDialog()
                  .then((fetchedFriends) {
                    if (dialogContext.mounted) {
                      setStateDialog(() {
                        friendsDetails = fetchedFriends;
                        isLoadingFriends = false;
                      });
                    }
                  })
                  .catchError((e) {
                    if (dialogContext.mounted) {
                      setStateDialog(() {
                        isLoadingFriends = false;
                      });
                      print("Error in fetchFriendsForDialog: $e");
                    }
                  });
            }

            return AlertDialog(
              title: const Text('Share with Friend'),
              content: SizedBox(
                width: double.maxFinite,
                child:
                    isLoadingFriends
                        ? const Center(child: CircularProgressIndicator())
                        : friendsDetails.isEmpty
                        ? const Text(
                          "No eligible friends to share with. Friends might already be part of the plan, have private profiles, or you have no friends added yet.",
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: friendsDetails.length,
                          itemBuilder: (BuildContext context, int index) {
                            final friend = friendsDetails[index];
                            return RadioListTile<String>(
                              title: Text(
                                "${friend.firstName} ${friend.lastName} (@${friend.username})",
                              ),
                              value: friend.username,
                              groupValue: selectedFriendUsername,
                              onChanged: (String? value) {
                                setStateDialog(() {
                                  selectedFriendUsername = value;
                                });
                              },
                            );
                          },
                        ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  onPressed:
                      (selectedFriendUsername == null || isLoadingFriends)
                          ? null
                          : () async {
                            Navigator.of(dialogContext).pop();
                            if (selectedFriendUsername != null &&
                                selectedFriendUsername!.isNotEmpty) {
                              try {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Sharing plan with $selectedFriendUsername...",
                                    ),
                                  ),
                                );
                                await provider.sharePlanWithUserByUsername(
                                  plan.planId,
                                  selectedFriendUsername!,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Plan shared successfully with $selectedFriendUsername!",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Failed to share plan: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  child: const Text('Share'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removeSharedUser(
    BuildContext context,
    TravelPlan plan,
    String userIdToRemove,
    TravelPlanProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove User?'),
            content: const Text(
              'Are you sure you want to remove this user from the plan?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Removing user...")));
        await provider.removeUserFromSharedPlan(plan.planId, userIdToRemove);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User removed successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to remove user: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleChecklistItem(
    BuildContext context,
    TravelPlan plan,
    int itemIndex,
    bool currentStatus,
  ) async {
    final provider = context.read<TravelPlanProvider>();
    try {
      await provider.toggleChecklistItemStatus(
        plan.planId,
        itemIndex,
        !currentStatus,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update checklist: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final planId = ModalRoute.of(context)?.settings.arguments as String?;
    final travelPlanProvider = context.watch<TravelPlanProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.user?.uid;

    final dateFormatter = DateFormat.yMMMMd();

    Widget buildCustomBackButton() {
      return InkWell(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: Colors.grey.shade400,
              width: 1.5,
            ), // Darker border
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 16),
              SizedBox(width: 6),
              Text(
                "Back",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (planId == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Added top margin for back button
                  padding: const EdgeInsets.only(top: 8.0),
                  child: buildCustomBackButton(),
                ),
                const SizedBox(height: 10),
                const Center(child: Text("Travel plan ID is missing.")),
              ],
            ),
          ),
        ),
      );
    }

    if (currentUserId == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Added top margin for back button
                  padding: const EdgeInsets.only(top: 8.0),
                  child: buildCustomBackButton(),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text("User not authenticated. Please sign in."),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<TravelPlan?>(
      stream: travelPlanProvider.getPlanStream(planId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final plan = snapshot.data;
        if (plan == null) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      // Added top margin for back button
                      padding: const EdgeInsets.only(top: 8.0),
                      child: buildCustomBackButton(),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text("Plan not found or you don't have access."),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final bool isCreator = plan.createdBy == currentUserId;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      // Added top margin for back button
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                      ), // Added bottom margin too
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: buildCustomBackButton(),
                      ),
                    ),
                    // const SizedBox(height: 8), // Adjusted spacing

                    // Plan Name as Title, aligned to start
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        // textAlign: TextAlign.start, // Default for Text in Column
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text("Start: ${dateFormatter.format(plan.startDate)}"),
                    Text("End: ${dateFormatter.format(plan.endDate)}"),
                    Text("Location: ${plan.location}"),
                    const SizedBox(height: 16),
                    if (isCreator)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.qr_code_2_rounded),
                            label: const Text("Share via QR"),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.shareQR,
                                arguments: plan.planId,
                              );
                            },
                            style: ElevatedButton.styleFrom(),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text("Share with Friend"),
                            onPressed:
                                () => _shareByUsernameDialog(
                                  context,
                                  plan,
                                  travelPlanProvider,
                                ),
                            style: ElevatedButton.styleFrom(),
                          ),
                        ],
                      )
                    else if (plan.sharedWith.contains(currentUserId))
                      ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text("View Plan QR"),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.shareQR,
                            arguments: plan.planId,
                          );
                        },
                        style: ElevatedButton.styleFrom(),
                      ),
                    const SizedBox(height: 20),
                    _sectionLabel('FLIGHT DETAILS'),
                    _infoBox(plan.flightDetails),
                    _sectionLabel('ACCOMMODATION'),
                    _infoBox(plan.accommodation),
                    _sectionLabel('ITINERARY'),
                    _buildItinerary(plan.itinerary),
                    _sectionLabel('OTHER NOTES'),
                    _buildNotes(plan.notes),
                    _sectionLabel('CHECKLIST'),
                    _buildChecklist(context, plan, isCreator),
                    if (isCreator && plan.sharedWith.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionLabel('SHARED WITH'),
                      _buildSharedUsersList(context, plan, travelPlanProvider),
                    ],
                    const SizedBox(height: 20),
                    if (isCreator)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.travelListDetailsEdit,
                                arguments: plan.planId,
                              );
                            },
                            child: const Text(
                              'Edit Details',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Delete Plan?'),
                                      content: const Text(
                                        'Are you sure you want to delete this travel plan? This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                try {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Deleting plan..."),
                                    ),
                                  );
                                  await travelPlanProvider.deletePlan(
                                    plan.planId,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Plan deleted successfully",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    int popCount = 0;
                                    Navigator.popUntil(context, (route) {
                                      popCount++;
                                      return route.settings.name ==
                                              AppRoutes.travelList ||
                                          popCount > 2;
                                    });
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Failed to delete plan: $e",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text(
                              'Delete Plan',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 1.1,
        color: Colors.black54,
      ),
    ),
  );

  Widget _infoBox(String content) {
    if (content.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          "Not specified",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
    );
  }

  Widget _buildItinerary(List<Map<String, dynamic>> itinerary) {
    if (itinerary.isEmpty) {
      return _infoBox("No itinerary items yet.");
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itinerary.length,
      itemBuilder: (context, index) {
        final day = itinerary[index];
        final activities = List<Map<String, dynamic>>.from(
          day['activities'] ?? [],
        );
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: ExpansionTile(
            title: Text(
              "Day ${day['day']}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children:
                activities.isEmpty
                    ? [
                      const ListTile(
                        title: Text("No activities for this day."),
                      ),
                    ]
                    : activities
                        .map(
                          (act) => ListTile(
                            leading: const Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: Colors.green,
                            ),
                            title: Text("${act['time']} - ${act['activity']}"),
                            dense: true,
                          ),
                        )
                        .toList(),
          ),
        );
      },
    );
  }

  Widget _buildNotes(List<String> notes) {
    if (notes.isEmpty) return _infoBox("No notes added.");
    return _infoBox(notes.map((note) => "• $note").join('\n'));
  }

  Widget _buildChecklist(
    BuildContext context,
    TravelPlan plan,
    bool isCreator,
  ) {
    final List<Map<String, dynamic>> checklistItems = plan.checklist;

    if (checklistItems.isEmpty) return _infoBox("No checklist items.");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            checklistItems.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, dynamic> item = entry.value;
              final title = item['title']?.toString() ?? 'Unnamed Item';
              final isDone = item['done'] as bool? ?? false;

              return CheckboxListTile(
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey[600] : Colors.black,
                  ),
                ),
                value: isDone,
                onChanged: (bool? newValue) {
                  if (newValue != null) {
                    if (isCreator) {
                      _toggleChecklistItem(context, plan, idx, isDone);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Only the plan creator can modify the checklist.",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).primaryColor,
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 0,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSharedUsersList(
    BuildContext context,
    TravelPlan plan,
    TravelPlanProvider travelPlanProvider,
  ) {
    if (plan.sharedWith.isEmpty) {
      return _infoBox("Not shared with anyone yet.");
    }

    final UserApi userApi = UserApi();
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).user?.uid;

    final displaySharedWith =
        plan.sharedWith
            .where((id) => id != currentUserId && id != plan.createdBy)
            .toList();
    if (displaySharedWith.isEmpty) {
      return _infoBox("Not shared with any other users yet.");
    }

    return Column(
      children:
          displaySharedWith.map((userId) {
            return FutureBuilder<UserModel?>(
              future: userApi.getUser(userId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text("Loading user..."),
                  );
                }
                if (userSnapshot.hasError ||
                    !userSnapshot.hasData ||
                    userSnapshot.data == null) {
                  return ListTile(
                    title: Text("Unknown user (ID: $userId)"),
                    trailing:
                        isCreator(plan, currentUserId)
                            ? IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              tooltip: 'Remove user',
                              onPressed:
                                  () => _removeSharedUser(
                                    context,
                                    plan,
                                    userId,
                                    travelPlanProvider,
                                  ),
                            )
                            : null,
                  );
                }
                final sharedUser = userSnapshot.data!;
                ImageProvider? avatarImage;
                if (sharedUser.profilePicture != null &&
                    sharedUser.profilePicture!.isNotEmpty) {
                  try {
                    avatarImage = MemoryImage(
                      base64Decode(sharedUser.profilePicture!),
                    );
                  } catch (e) {
                    print(
                      "Error decoding base64 for shared user ${sharedUser.username}: $e",
                    );
                    avatarImage = null;
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: avatarImage,
                      child:
                          (avatarImage == null)
                              ? Text(
                                sharedUser.firstName.isNotEmpty
                                    ? sharedUser.firstName[0].toUpperCase()
                                    : (sharedUser.username.isNotEmpty
                                        ? sharedUser.username[0].toUpperCase()
                                        : 'U'),
                              )
                              : null,
                    ),
                    title: Text(
                      "${sharedUser.firstName} ${sharedUser.lastName} (@${sharedUser.username})",
                    ),
                    trailing:
                        isCreator(plan, currentUserId)
                            ? IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              tooltip: 'Remove user',
                              onPressed:
                                  () => _removeSharedUser(
                                    context,
                                    plan,
                                    userId,
                                    travelPlanProvider,
                                  ),
                            )
                            : null,
                  ),
                );
              },
            );
          }).toList(),
    );
  }

  bool isCreator(TravelPlan plan, String? currentUserId) {
    return plan.createdBy == currentUserId;
  }
}
