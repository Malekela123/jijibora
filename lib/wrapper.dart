import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'navbar/bottomnavadmin.dart';
import 'navbar/bottomnavcollector.dart';
import 'navbar/bottomnavuser.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Kama mtumiaji hajaingia (Logged Out) mpeleke Login
        if (!snapshot.hasData) {
          return const Login();
        }

        // 2. Kama ameingia, soma Role yake kutoka Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
              String role = roleSnapshot.data!.get('role');

              // Maelekezo kulingana na Role
              if (role == 'admin') {
                return const BottomNavAdmin();
              } else if (role == 'collector') {
                return const BottomNavCollector();
              } else {
                return const BottomNavUser();
              }
            }

            // Kama role haijulikani, rudi Login kwa usalama
            return const Login();
          },
        );
      },
    );
  }
}