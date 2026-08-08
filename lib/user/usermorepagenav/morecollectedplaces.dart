import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ionicons/ionicons.dart';

class MoreCollectedPlaces extends StatefulWidget {
  const MoreCollectedPlaces({super.key});

  @override
  State<MoreCollectedPlaces> createState() => _MoreCollectedPlacesState();
}

class _MoreCollectedPlacesState extends State<MoreCollectedPlaces> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Collected Places'),
      ),
    );
  }
}