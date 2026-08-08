import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:html' as html; // Inatumika kufungua dialer ya simu kwenye Flutter Web (Chrome)
import 'chat_room.dart'; // Import ya chumba cha chati kwa kuwa vipo folda moja

class MoreChat extends StatefulWidget {
  const MoreChat({super.key});

  @override
  State<MoreChat> createState() => _MoreChatState();
}

class _MoreChatState extends State<MoreChat> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function ya kupiga simu ya kawaida (Normal Call) kutoka kwenye Kivinjari/Simu
  void _makeNormalCall(String phoneNumber) {
    if (phoneNumber.trim().isEmpty || phoneNumber == 'Hana namba') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Namba ya simu ya mtumiaji huyu haipatikani!"), 
          backgroundColor: Colors.red
        ),
      );
      return;
    }
    
    try {
      // Inafungua Dialer ya simu au mfumo wa kupiga simu wa Chrome kiotomatiki
      html.window.open('tel:$phoneNumber', '_self');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Imeshindwa kuanzisha simu: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Function iliyoboreshwa: Inafungua chumba cha chati (In-App Chat) rasmi
  void _openInAppChat(String targetUserId, String targetUserName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          receiverId: targetUserId,
          receiverName: targetUserName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? currentUid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Mawasiliano & Chati",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Inavuta watumiaji wote waliopo kwenye mfumo wetu kutoka Firestore
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Hakuna watumiaji wengine waliopatikana kwenye mfumo kwa sasa."),
            );
          }

          // Kuchuja list ili isijionyeshe nafsi yako (Mtumiaji aliyelogin kwa sasa)
          final users = snapshot.data!.docs.where((doc) => doc.id != currentUid).toList();

          if (users.isEmpty) {
            return const Center(child: Text("Hakuna watumiaji wengine kwenye mfumo bado."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              String userId = users[index].id;
              String name = userData['name'] ?? 'Mtumiaji asiye na jina';
              String phone = userData['phone'] ?? 'Hana namba';
              String role = userData['role'] ?? 'citizen';

              // Kubadilisha rangi kulingana na Role (Admin = Nyekundu, Collector = Bluu, Citizen = Kijani)
              Color roleColor = Colors.green;
              if (role == 'admin') roleColor = Colors.redAccent;
              if (role == 'collector') roleColor = Colors.blue;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: roleColor.withOpacity(0.1),
                    child: Icon(Ionicons.person, color: roleColor),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(fontSize: 9, color: roleColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text("Simu: $phone", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Kitufe cha Chati ya Ndani ya App (Sasa kinafungua ChatRoomScreen)
                      IconButton(
                        icon: const Icon(Ionicons.chatbubble_ellipses_outline, color: Colors.green, size: 22),
                        onPressed: () => _openInAppChat(userId, name),
                        tooltip: "Chat Ndani ya App",
                      ),
                      const SizedBox(width: 4),
                      // 2. Kitufe cha Kupiga Simu ya Kawaida (Normal Call)
                      IconButton(
                        icon: const Icon(Ionicons.call_outline, color: Colors.blue, size: 22),
                        onPressed: () => _makeNormalCall(phone),
                        tooltip: "Piga Simu ya Kawaida",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}