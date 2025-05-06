import 'package:flutter/material.dart';

class Friends extends StatelessWidget {
  const Friends({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> users = [
      {
        "username": "tralalelo_tralala",
        "name": "Tralalelo Tralala",
        "interests": ["Museums", "Art", "History"],
        "travelStyles": ["City Tours", "Luxury"],
        "avatar":
            "https://static.wikia.nocookie.net/incredibox-sprunki-pyramixed-fanon/images/d/d6/TralaleroAllMode_%281%29.svg/revision/latest/scale-to-width/360?cb=20250412085013",
      },
      {
        "username": "tung_sahur",
        "name": "Tung tung tungt tung Sahur",
        "interests": ["Hiking", "Photography", "Camping"],
        "travelStyles": ["Backpacking", "Adventure"],
        "avatar":
            "https://i.ytimg.com/vi/cDgsVs8_ms4/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBXBues_uAQ5WxDp9-Ot3WSPkXiKw",
      },
      {
        "username": "bomb_croc",
        "name": "Bombardino Crocodilo",
        "interests": ["Beaches", "Sunsets", "Food"],
        "travelStyles": ["Relaxed", "Solo Travel"],
        "avatar":
            "https://static.wikia.nocookie.net/brainrotnew/images/1/10/Bombardiro_Crocodilo.jpg/revision/latest?cb=20250417102447",
      }
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Find People', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or username',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                label: const Text("Filter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1642E),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(user['avatar']),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['username'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(user['name'],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 8),
                                const Text("Interests:",
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: user['interests']
                                      .map<Widget>((item) => Chip(
                                            label: Text(item,
                                                style: const TextStyle(fontSize: 10)),
                                            backgroundColor:
                                                const Color(0xFFFCDD9D),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                const Text("Travel Styles:",
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: user['travelStyles']
                                      .map<Widget>((item) => Chip(
                                            label: Text(item,
                                                style: const TextStyle(fontSize: 10)),
                                            backgroundColor:
                                                const Color(0xFFC4C3E3),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
