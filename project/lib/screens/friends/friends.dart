import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/api/users_api.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/profile/view_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final UserApi _usersApi = UserApi();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  String _search = '';
  Set<String> _filterInterests = {};
  Set<String> _filterStyles = {};

  static const List<String> _allInterestTags = [
    "Local Food", "Fancy Cuisine", "Locals", "Rich History",
    "Beaches", "Mountains", "Malls", "Festivals",
    "Solo Travel", "Adventure", "Luxury", "Photography",
    "Museums",
  ];
  static const List<String> _allStyleTags = [
    "Solo", "Group", "Backpacking", "Long-Term", "Short-Term"
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(() {
      setState(() => _search = _searchController.text.trim().toLowerCase());
    });
  }

  Future<void> _loadUsers() async {
    final users = await _usersApi.getAllUsers(); // only public
    setState(() => _allUsers = users);
  }

  List<UserModel> get _filteredUsers {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return _allUsers.where((u) {
      
      if (u.userId == currentUid) return false; // exclude self from results

      final fullname = "${u.firstName} ${u.lastName}".toLowerCase();
      final matchesSearch =
          u.username.toLowerCase().contains(_search) || fullname.contains(_search);

      final sharesInterest = u.interests.any(_filterInterests.contains);
      final sharesStyle    = u.travelStyles.any(_filterStyles.contains);

      // only show if at least one filter set and at least one tag matches
      final passesFilter = (_filterInterests.isNotEmpty || _filterStyles.isNotEmpty)
          ? (sharesInterest || sharesStyle)
          : false;

      return matchesSearch && passesFilter;
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,                   
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: StatefulBuilder(
            builder: (innerCtx, setInner) {
              Widget _buildChips(List<String> tags, Set<String> sel) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: tags.map((tag) {
                    final isSel = sel.contains(tag);
                    return FilterChip(
                      label: Text(tag, style: GoogleFonts.lexend(fontSize: 12)),
                      selected: isSel,
                      onSelected: (yes) => setInner(() {
                        yes ? sel.add(tag) : sel.remove(tag);
                      }),
                    );
                  }).toList(),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Filter Interests",
                      style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildChips(_allInterestTags, _filterInterests),
                  const SizedBox(height: 16),
                  Text("Filter Travel Styles",
                      style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildChips(_allStyleTags, _filterStyles),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // re-run the list filter
                      Navigator.pop(context);
                    },
                    child: const Text("Apply Filters"),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFFF1642E);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Find People', style: GoogleFonts.lexend(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(children: [
          TextField(
            controller: _searchController,
            style: GoogleFonts.lexend(),
            decoration: InputDecoration(
              hintText: 'Search by name or username',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _openFilterSheet,
              icon: const Icon(Icons.filter_list),
              label: Text("Filter", style: GoogleFonts.lexend()),
              style: ElevatedButton.styleFrom(
                backgroundColor: highlightColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (ctx, i) {
                final u = _filteredUsers[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage:
                          NetworkImage(u.profilePicture ?? ''), 
                    ),
                    title: Text(u.username,
                        style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text("${u.firstName} ${u.lastName}",
                        style: GoogleFonts.lexend(color: Colors.grey)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PublicProfileScreen(userId: u.userId),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
