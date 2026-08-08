import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ionicons/ionicons.dart';

class MoreNearestBin extends StatefulWidget {
  const MoreNearestBin({super.key});

  @override
  State<MoreNearestBin> createState() => _MoreNearestBinState();
}

class _MoreNearestBinState extends State<MoreNearestBin> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Nearest Bin'),
      ),
    );
  }
}