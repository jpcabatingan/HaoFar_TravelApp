import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/api/users_api.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/friends/private_profile.dart';
import 'package:project/screens/profile/view_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/user_provider.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final UserApi _userApi = UserApi();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _searchTerm = '';

  Set<String> _filterInterests = {};
  Set<String> _filterStyles = {};

  static const List<String> _allInterestTags = [
    "Local Food",
    "Fancy Cuisine",
    "Locals",
    "Rich History",
    "Beaches",
    "Mountains",
    "Malls",
    "Festivals",
  ];
  static const List<String> _allStyleTags = [
    "Solo",
    "Group",
    "Backpacking",
    "Long-Term",
    "Short-Term",
  ];

  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();

    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _userProvider.addListener(_onProfileChanged);

    _loadUsers();

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
        _applyFiltersAndSearch();
      });
    });
  }

  void _onProfileChanged() {
    final currentUser = _userProvider.user;
    if (currentUser != null) {
      setState(() {
        _filterInterests = currentUser.interests.toSet();
        _filterStyles = currentUser.travelStyles.toSet();
        _applyFiltersAndSearch();
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userApi.getAllUsers();
      if (!mounted) return;

      final me = _userProvider.user;
      if (me != null) {
        _filterInterests = me.interests.toSet();
        _filterStyles = me.travelStyles.toSet();
      }

      setState(() {
        _allUsers = users;
        _applyFiltersAndSearch(); // Initial filter application
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  void _applyFiltersAndSearch() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    var list = List<UserModel>.from(_allUsers);

    if (currentUid != null) {
      list.removeWhere((u) => u.userId == currentUid);
    }

    if (_searchTerm.isNotEmpty) {
      list =
          list.where((u) {
            final fullName = '${u.firstName} ${u.lastName}'.toLowerCase();
            return fullName.contains(_searchTerm) ||
                u.username.toLowerCase().contains(_searchTerm);
          }).toList();
    }

    final hasI = _filterInterests.isNotEmpty;
    final hasS = _filterStyles.isNotEmpty;

    if (hasI || hasS) {
      list =
          list.where((u) {
            // User must match if any interest filters are active AND they have common interests
            // OR if any style filters are active AND they have common styles.
            // If both interest and style filters are active, they need to match at least one category.
            final matchI =
                hasI ? u.interests.any(_filterInterests.contains) : false;
            final matchS =
                hasS ? u.travelStyles.any(_filterStyles.contains) : false;

            if (hasI && hasS) {
              // If both filter categories are active, user must match something in both
              return u.interests.any(_filterInterests.contains) &&
                  u.travelStyles.any(_filterStyles.contains);
            } else if (hasI) {
              // Only interest filters active
              return matchI;
            } else if (hasS) {
              // Only style filters active
              return matchS;
            }
            return false; // Should not happen if hasI or hasS is true
          }).toList();
    }

    // If no search term is present and no filters are selected, show no users
    // This prompts the user to use search or filters.
    if (_searchTerm.isEmpty && !hasI && !hasS) {
      list = [];
    }

    setState(() => _filteredUsers = list);
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder: (modalCtx, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Filter by Interests",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildChipGroup(
                        _allInterestTags,
                        _filterInterests,
                        setModalState,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Filter by Travel Styles",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildChipGroup(
                        _allStyleTags,
                        _filterStyles,
                        setModalState,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _filterInterests.clear();
                                _filterStyles.clear();
                              });
                            },
                            child: Text(
                              "Clear All",
                              style: GoogleFonts.roboto(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(_applyFiltersAndSearch);
                              Navigator.pop(modalCtx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              "Apply Filters",
                              style: GoogleFonts.roboto(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildChipGroup(
    List<String> tags,
    Set<String> selectedSet,
    StateSetter setModalState,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children:
          tags.map((tag) {
            final sel = selectedSet.contains(tag);
            return FilterChip(
              label: Text(
                tag,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: sel ? Colors.white : Colors.black87,
                ),
              ),
              selected: sel,
              onSelected:
                  (b) => setModalState(() {
                    if (b) {
                      selectedSet.add(tag);
                    } else {
                      selectedSet.remove(tag);
                    }
                  }),
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.8),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      sel ? Theme.of(context).primaryColor : Colors.grey[400]!,
                ),
              ),
            );
          }).toList(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _userProvider.removeListener(_onProfileChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFFF1642E);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 204, 235),
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 50),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 204, 235),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Text(
                  "Find Friends",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.roboto(),
                  decoration: InputDecoration(
                    hintText: 'Search by name or username...',
                    hintStyle: GoogleFonts.roboto(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: _openFilterSheet,
                    icon: const Icon(Icons.filter_list_rounded, size: 20),
                    label: Text(
                      "Filters",
                      style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: highlightColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_filteredUsers.isEmpty &&
                  (_searchTerm.isNotEmpty ||
                      _filterInterests.isNotEmpty ||
                      _filterStyles.isNotEmpty))
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "No users match your search or filter criteria.\nTry adjusting your filters or search term.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                )
              else if (_filteredUsers
                  .isEmpty) // This handles the initial state or when filters/search are cleared
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Search for users or apply filters to find people.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (ctx, i) {
                      final user = _filteredUsers[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                user.profilePicture != null &&
                                        user.profilePicture!.isNotEmpty
                                    ? MemoryImage(
                                      base64Decode(user.profilePicture!),
                                    )
                                    : null,
                            child:
                                (user.profilePicture == null ||
                                        user.profilePicture!.isEmpty)
                                    ? Text(
                                      user.firstName.isNotEmpty
                                          ? user.firstName[0].toUpperCase()
                                          : (user.username.isNotEmpty
                                              ? user.username[0].toUpperCase()
                                              : "?"),
                                      style: GoogleFonts.roboto(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                    : null,
                          ),
                          title: Text(
                            "${user.firstName} ${user.lastName}",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "@${user.username}",
                            style: GoogleFonts.roboto(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            if (user.isProfilePublic) {
                              Navigator.push(
                                context,
                                // Ensure PublicProfileScreen is correctly imported and defined
                                MaterialPageRoute(
                                  builder:
                                      (_) => PublicProfileScreen(
                                        userId: user.userId,
                                      ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                // Ensure PrivateProfilePlaceholderScreen is correctly imported and defined
                                MaterialPageRoute(
                                  builder:
                                      (_) => PrivateProfilePlaceholderScreen(
                                        user: user,
                                      ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              // The duplicated block that was here has been removed.
            ],
          ),
        ),
      ),
    );
  }
}
