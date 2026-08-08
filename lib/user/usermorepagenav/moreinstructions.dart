import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ionicons/ionicons.dart';

class MoreInstructions extends StatefulWidget {
  const MoreInstructions({super.key});

  @override
  State<MoreInstructions> createState() => _MoreInstructionsState();
}

class _MoreInstructionsState extends State<MoreInstructions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
      ),
      body: const Center(
        child: Text('Instructions'),
      ),
    );
  }
}