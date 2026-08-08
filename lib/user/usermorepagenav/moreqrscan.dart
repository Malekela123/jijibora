import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ionicons/ionicons.dart';

class MoreQrScan extends StatefulWidget {
  const MoreQrScan({super.key});

  @override
  State<MoreQrScan> createState() => _MoreQrScanState();
}

class _MoreQrScanState extends State<MoreQrScan> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('QR Scanner'),
      ),
    );
  }
}