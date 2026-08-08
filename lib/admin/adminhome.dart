import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../login.dart';
import '../user/usermorepagenav/morechat.dart';
import 'package:eco_clean_mobile_app/user/usermorepagenav/chat_room.dart';


class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _selectedLocation = 'Kampasi Kuu';

  final List<String> _locations = [
    'Kampasi Kuu',
    'Hosteli za Chuo',
    'Eneo la Maktaba',
    'Utawala / Ofisi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Ionicons.log_out_outline, color: Colors.redAccent),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chuja Mapipa kwa Eneo:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  icon: const Icon(Ionicons.location, color: Colors.green),
                  items: _locations.map((String loc) {
                    return DropdownMenuItem<String>(
                      value: loc,
                      child: Text(loc, style: const TextStyle(fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLocation = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.green,
                      tabs: [
                        Tab(text: "Users"),
                        Tab(text: "Collectors"),
                        Tab(text: "Dustbins"),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildAllUsersStream(role: 'user'),
                          
                          _buildAllUsersStream(role: 'collector'),
                          
                          _buildFilteredDustbinsStream(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllUsersStream({required String role}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Hakuna ${role == 'user' ? 'Mwananchi' : 'Mkusanyaji'} aliyesajiliwa kwenye mfumo.",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final usersDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: usersDocs.length,
          itemBuilder: (context, index) {
            final userDoc = usersDocs[index]; // IMEBADILISHWA: Tunahitaji pia document ID (UID)
            final userData = userDoc.data() as Map<String, dynamic>;
            
            String email = userData['email'] ?? 'Haina Email';
            String phone = userData['phone'] ?? 'Haina Namba';

            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: role == 'user' ? Colors.blue[50] : Colors.orange[50],
                  child: Icon(
                    role == 'user' ? Icons.person : Icons.local_shipping,
                    color: role == 'user' ? Colors.blue : Colors.orange,
                  ),
                ),
                title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text("Simu: $phone"),
                trailing: const Icon(Ionicons.chatbubble_ellipses_outline, color: Colors.green, size: 20),
                
                // IMEONGEZWA: Admin akigusa hapa, inamfungulia ukurasa wa Live Chat na mtumiaji huyo
               onTap: () {
  // Chukua jina la mtumiaji kutoka kwenye userDoc (kama field inaitwa 'name' au 'username')
  String userName = userDoc['name'] ?? 'Mtumiaji'; 

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatRoomScreen(
        receiverId: userDoc.id,       // UID ya mtumiaji kutoka Firestore
        receiverName: userName,       // Jina litakalooonekana juu kwenye AppBar ya Chat
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilteredDustbinsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('dustbins')
          .where('location', isEqualTo: _selectedLocation)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Hakuna Mapipa yaliyopo eneo la $_selectedLocation.",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final binDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: binDocs.length,
          itemBuilder: (context, index) {
            final binData = binDocs[index].data() as Map<String, dynamic>;
            
            String binId = binDocs[index].id;
            String type = binData['type'] ?? 'Mchanganyiko';
            String fillLevel = binData['fillLevel'] ?? '0%';

            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.delete, color: Colors.green),
                ),
                title: Text("Pipa ID: $binId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text("Aina: $type"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Ujazo: $fillLevel",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}