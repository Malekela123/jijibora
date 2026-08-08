import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AdminNotification extends StatefulWidget {
  const AdminNotification({super.key});

  @override
  State<AdminNotification> createState() => _AdminNotificationState();
}

class _AdminNotificationState extends State<AdminNotification> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function ya kusasisha taarifa Firestore na kumgawia mkusanyaji jukumu
  Future<void> _assignCollector(String reportId, String collectorId, String collectorName) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'collectorId': collectorId,
        'collectorName': collectorName,
        'status': 'Inafanyiwa Kazi', // Inabadilika kutoka Inasubiri
        'assignedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Jukumu limepewa kwa $collectorName kwa mafanikio!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Imeshindwa kumgawia mkusanyaji: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function inayofungua kijiduka cha chini (Bottom Sheet) kuonyesha wakusanyaji
  void _showCollectorSelectionSheet(BuildContext context, String reportId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chagua Mkusanyaji Taka",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // MUHIMU: Inavuta watumiaji ambao role yao ni 'collector' pekee
                  stream: _firestore
                      .collection('users')
                      .where('role', isEqualTo: 'collector')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.green));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("Hakuna wakusanyaji taka waliosajiliwa kwenye mfumo bado."),
                      );
                    }

                    final collectors = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: collectors.length,
                      itemBuilder: (context, index) {
                        final collector = collectors[index].data() as Map<String, dynamic>;
                        String id = collectors[index].id;
                        String name = collector['name'] ?? 'Mkusanyaji asiye na jina';
                        String phone = collector['phone'] ?? 'Hana namba';

                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Ionicons.person, color: Colors.white),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("Simu: $phone"),
                          trailing: const Icon(Ionicons.chevron_forward, color: Colors.grey),
                          onTap: () {
                            Navigator.pop(context); // Funga bottom sheet
                            _assignCollector(reportId, id, name); // Gawa jukumu
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Taarifa za Dharura",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          bottom: const TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: [
              Tab(
                icon: Icon(Ionicons.alert_circle_outline),
                text: "Uchafu Ulioripotiwa",
              ),
              Tab(
                icon: Icon(Ionicons.trash_bin_outline),
                text: "Mapipa Yaliyojaa",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCitizenReportsStream(),
            _buildFullDustbinsStream(),
          ],
        ),
      ),
    );
  }

  // 1. Stream ya Ripoti za Uchafu kutoka kwa Wananchi
  Widget _buildCitizenReportsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Hakuna taarifa mpya za uchafu zilizoripotiwa."));
        }

        final reports = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final doc = reports[index];
            final report = doc.data() as Map<String, dynamic>;
            String reportId = doc.id;

            String locationText = 'Eneo Halijulikani';
            if (report['location'] != null && report['location'] is GeoPoint) {
              GeoPoint geoPoint = report['location'] as GeoPoint;
              locationText = "Lat: ${geoPoint.latitude.toStringAsFixed(4)}, Lon: ${geoPoint.longitude.toStringAsFixed(4)}";
            } else if (report['location'] is String) {
              locationText = report['location'];
            }

            String description = report['description'] ?? 'Hakuna maelezo yaliyowekwa.';
            String status = report['status'] ?? 'Inasubiri';
            String? assignedTo = report['collectorName'];

            // Kubadilisha rangi kutokana na hatua ya usafi (Status)
            Color statusColor = status == 'Inasubiri' ? Colors.orange : Colors.green;
            Color statusBg = status == 'Inasubiri' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1);

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Ionicons.warning, color: status == 'Inasubiri' ? Colors.redAccent : Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  locationText,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4),
                    ),
                    
                    // Kama tayari ameshapewa mtu, onyesha jina lake hapa
                    if (assignedTo != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Ionicons.person_outline, size: 14, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            "Amepewa: $assignedTo",
                            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: status == 'Inasubiri'
                          ? OutlinedButton.icon(
                              onPressed: () => _showCollectorSelectionSheet(context, reportId),
                              icon: const Icon(Ionicons.person_add_outline, size: 16),
                              label: const Text("Tuma Mkusanyaji (Assign)"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: null, // Inakuwa disabled kwa sababu tayari ina mkusanyaji
                              icon: const Icon(Ionicons.checkmark_circle, size: 16),
                              label: const Text("Tayari Imetumwa"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.grey[600],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
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

  // 2. Stream ya Mapipa Yaliyojaa
  Widget _buildFullDustbinsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('dustbins')
          .where('isFull', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Safi sana! Hakuna pipa lililofurika kwa sasa."));
        }

        final bins = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: bins.length,
          itemBuilder: (context, index) {
            final bin = bins[index].data() as Map<String, dynamic>;
            String binId = bins[index].id;
            
            String locationText = 'Eneo halijatajwa';
            if (bin['location'] != null && bin['location'] is GeoPoint) {
              GeoPoint geoPoint = bin['location'] as GeoPoint;
              locationText = "Lat: ${geoPoint.latitude.toStringAsFixed(4)}, Lon: ${geoPoint.longitude.toStringAsFixed(4)}";
            } else if (bin['location'] is String) {
              locationText = bin['location'];
            }

            String fillLevel = bin['fillLevel']?.toString() ?? '100%';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.red[100]!),
              ),
              color: Colors.red[50]?.withOpacity(0.3),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Ionicons.trash_sharp, color: Colors.white, size: 20),
                ),
                title: Text(
                  "Pipa Limejaa ($fillLevel)",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                subtitle: Text("ID: $binId\nEneo: $locationText", style: const TextStyle(height: 1.3)),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Unaweza kuongeza bottom sheet kama ile ya juu hapa pia baadaye!
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Zoa Taka", style: TextStyle(fontSize: 12)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}