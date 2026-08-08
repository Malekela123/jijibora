import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
// import ya kipekee kwa ajili ya kufungua link kwenye Flutter Web (Chrome)
import 'dart:html' as html; 

class CollectorHome extends StatefulWidget {
  const CollectorHome({super.key});

  @override
  State<CollectorHome> createState() => _CollectorHomeState();
}

class _CollectorHomeState extends State<CollectorHome> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  User? get user => _auth.currentUser;

  Future<void> signout() async {
    await _auth.signOut();
  }

  // FUNCTION BORA KWA WEB: Inafungua Google Maps kwenye Tab mpya ya Chrome bila kuhitaji url_launcher
  void _openMapOnWeb(double latitude, double longitude) {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    try {
      html.window.open(googleMapsUrl, '_blank'); // '_blank' inalazimisha ifunguke kwenye tab mpya
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imeshindwa kufungua ramani: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeTask(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': 'Imekamilika',
        'completedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hongera! Taarifa ya usafi imesasishwa kikamilifu."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imeshindwa kusasisha: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mkusanyaji Taka",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              Text("${user?.email}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          actions: [
            IconButton(icon: const Icon(Ionicons.log_out_outline, color: Colors.redAccent), onPressed: signout),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: [
              Tab(icon: Icon(Ionicons.clipboard_outline), text: "Kazi Zangu"),
              Tab(icon: Icon(Ionicons.checkmark_done_circle_outline), text: "Zilizokamilika"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCollectorTasksStream('Inafanyiwa Kazi'),
            _buildCollectorTasksStream('Imekamilika'),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectorTasksStream(String statusTarget) {
    if (user == null) return const Center(child: Text("Tafadhali login kwanza."));

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('reports')
          .where('collectorId', isEqualTo: user!.uid)
          .where('status', isEqualTo: statusTarget)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    statusTarget == 'Inafanyiwa Kazi' ? Ionicons.happy_outline : Ionicons.folder_open_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusTarget == 'Inafanyiwa Kazi'
                        ? "Safi sana! Huna kazi yoyote uliyopangiwa kwa sasa."
                        : "Bado haujakamilisha kazi yoyote.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }

        final tasks = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final doc = tasks[index];
            final task = doc.data() as Map<String, dynamic>;
            String taskId = doc.id;

            String locationText = 'Eneo Halijulikani';
            GeoPoint? currentGeoPoint; 

            if (task['location'] != null && task['location'] is GeoPoint) {
              currentGeoPoint = task['location'] as GeoPoint;
              locationText = "Lat: ${currentGeoPoint.latitude.toStringAsFixed(4)}, Lon: ${currentGeoPoint.longitude.toStringAsFixed(4)}";
            } else if (task['location'] is String) {
              locationText = task['location'];
            }

            String description = task['description'] ?? 'Hakuna maelezo.';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            statusTarget == 'Inafanyiwa Kazi' ? Ionicons.location : Ionicons.checkmark_circle,
                            color: statusTarget == 'Inafanyiwa Kazi' ? Colors.orange : Colors.green,
                          ),
                          onPressed: currentGeoPoint != null
                              ? () => _openMapOnWeb(currentGeoPoint!.latitude, currentGeoPoint!.longitude)
                              : null, 
                          tooltip: "Fungua kwenye Ramani",
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: InkWell(
                            onTap: currentGeoPoint != null
                                ? () => _openMapOnWeb(currentGeoPoint!.latitude, currentGeoPoint!.longitude)
                                : null,
                            child: Text(
                              locationText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15, 
                                color: Colors.blueAccent, 
                                decoration: TextDecoration.underline, 
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 15),
                    
                    if (statusTarget == 'Inafanyiwa Kazi')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _completeTask(taskId),
                          icon: const Icon(Ionicons.checkmark, size: 16),
                          label: const Text("Nimeshasafisha (Complete)"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Ionicons.checkmark_done, color: Colors.green, size: 16),
                            SizedBox(width: 5),
                            Text(
                              "Kazi Hii Imekamilika",
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}