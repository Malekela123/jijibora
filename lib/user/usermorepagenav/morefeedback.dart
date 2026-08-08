import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ionicons/ionicons.dart';

class MoreFeedback extends StatefulWidget {
  const MoreFeedback({super.key});

  @override
  State<MoreFeedback> createState() => _MoreFeedbackState();
}

class _MoreFeedbackState extends State<MoreFeedback> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Feedback'),
      ),
    );
  }
}