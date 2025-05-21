import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/api/users_api.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/friends/private_profile.dart';
import 'package:project/screens/profile/view_profile_screen.dart'; // Your existing public profile screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Assuming you might use UserProvider later
import 'package:project/providers/user_provider.dart'; // For fetching specific user if needed

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final UserApi _userApi = UserApi();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = []; // Separate list for filtered results
  bool _isLoading = true;
  String _searchTerm = ''; // Renamed from _search for clarity

  // Filter criteria
  Set<String> _filterInterests = {};
  Set<String> _filterStyles = {};

  // Available tags for filtering (can be fetched or hardcoded)
  static const List<String> _allInterestTags = [
    "Local Food",
    "Fancy Cuisine",
    "Locals",
    "Rich History",
    "Beaches",
    "Mountains",
    "Malls",
    "Festivals",
    "Solo Travel",
    "Adventure",
    "Luxury",
    "Photography",
    "Museums",
    "Nightlife",
    "Art & Culture",
    "Shopping",
    "Sports",
    "Wellness & Spa",
    "Nature & Parks",
    "Road Trips",
  ];
  static const List<String> _allStyleTags = [
    "Solo",
    "Couple",
    "Family",
    "Group",
    "Backpacking",
    "Budget-Friendly",
    "Mid-Range",
    "Luxury",
    "Long-Term",
    "Short-Term",
    "Weekend Getaway",
    "Digital Nomad",
    "Slow Travel",
    "Fast-Paced",
    "Off-the-beaten-path",
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(() {
      // Call _filterUsers directly when search term changes
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
        _applyFiltersAndSearch(); // Apply filters and search
      });
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userApi.getAllUsers();
      if (!mounted) return;
      setState(() {
        _allUsers = users;
        _applyFiltersAndSearch(); // Initial filter/search application
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

    List<UserModel> usersToFilter = List.from(
      _allUsers,
    ); // Start with all users

    // Exclude current user
    if (currentUid != null) {
      usersToFilter.removeWhere((user) => user.userId == currentUid);
    }

    // Apply search term
    if (_searchTerm.isNotEmpty) {
      usersToFilter =
          usersToFilter.where((user) {
            final fullName = "${user.firstName} ${user.lastName}".toLowerCase();
            final username = user.username.toLowerCase();
            return fullName.contains(_searchTerm) ||
                username.contains(_searchTerm);
          }).toList();
    }

    // Apply interest and style filters
    final hasInterestFilters = _filterInterests.isNotEmpty;
    final hasStyleFilters = _filterStyles.isNotEmpty;

    if (hasInterestFilters || hasStyleFilters) {
      usersToFilter =
          usersToFilter.where((user) {
            bool matchesInterests =
                !hasInterestFilters; // True if no interest filters
            if (hasInterestFilters) {
              matchesInterests = user.interests.any(_filterInterests.contains);
            }

            bool matchesStyles = !hasStyleFilters; // True if no style filters
            if (hasStyleFilters) {
              matchesStyles = user.travelStyles.any(_filterStyles.contains);
            }

            // If both filter types are active, user must match at least one from each active type (AND logic for types, OR within type)
            // If only one filter type is active, user must match that type.
            if (hasInterestFilters && hasStyleFilters) {
              return matchesInterests &&
                  matchesStyles; // Must match both if both are active
            } else if (hasInterestFilters) {
              return matchesInterests;
            } else if (hasStyleFilters) {
              return matchesStyles;
            }
            return false; // Should not reach here if logic is correct
          }).toList();
    }

    // If search is empty AND no filters are applied, show no users.
    if (_searchTerm.isEmpty && !hasInterestFilters && !hasStyleFilters) {
      setState(() => _filteredUsers = []);
      return;
    }

    setState(() => _filteredUsers = usersToFilter);
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(modalContext).viewInsets.bottom +
                    20, // Adjust for keyboard
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                // Make content scrollable
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
                            style: GoogleFonts.roboto(color: Colors.redAccent),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Apply the filters to the main list
                            setState(() {
                              _applyFiltersAndSearch();
                            });
                            Navigator.pop(modalContext); // Close the modal
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(
                                  context,
                                ).primaryColor, // Use theme color
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            textStyle: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
        );
      },
    );
  }

  Widget _buildChipGroup(
    List<String> tags,
    Set<String> selectedSet,
    StateSetter setModalState,
  ) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 6.0,
      children:
          tags.map((tag) {
            final isSelected = selectedSet.contains(tag);
            return FilterChip(
              label: Text(
                tag,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setModalState(() {
                  // Update the state within the modal
                  if (selected) {
                    selectedSet.add(tag);
                  } else {
                    selectedSet.remove(tag);
                  }
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(
                context,
              ).primaryColor.withOpacity(0.8), // A bit of transparency
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400]!,
                ),
              ),
            );
          }).toList(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(
      0xFFF1642E,
    ); 

    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        title: Text(
          'Find People',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, 
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              style: GoogleFonts.roboto(),
              decoration: InputDecoration(
                hintText: 'Search by name or username...',
                hintStyle: GoogleFonts.roboto(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // More rounded
                  borderSide: BorderSide.none, // No border for filled style
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter Button
            Align(
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
            const SizedBox(height: 16),
            // User List
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
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
            else if (_filteredUsers.isEmpty &&
                _searchTerm.isEmpty &&
                _filterInterests.isEmpty &&
                _filterStyles.isEmpty)
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
                          backgroundColor:
                              Colors.grey[300], // Placeholder background
                          backgroundImage:
                              user.profilePicture != null &&
                                      user.profilePicture!.isNotEmpty
                                  ? NetworkImage(user.profilePicture!)
                                  : null, // Use null for NetworkImage to show child if no image
                          child:
                              (user.profilePicture == null ||
                                      user.profilePicture!.isEmpty)
                                  ? Text(
                                    // Display initials if no image
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
          ],
        ),
      ),
    );
  }
}
