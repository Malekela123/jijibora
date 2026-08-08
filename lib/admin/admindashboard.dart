import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'adminnotification.dart'; // Screen ya ripoti za dharura
import 'register_bin.dart';     // Screen ya kusajili mapipa ya IoT
import '../user/usermorepagenav/morechat.dart'; // Screen ya Mawasiliano/Chat

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "EcoClean Admin",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
            ),
            Text(
              "Mfumo wa Usimamizi wa Usafi",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Ionicons.log_out_outline, color: Colors.redAccent),
            onPressed: () {
              // Mfumo wa Logout utakuja hapa
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salamu na Karibu
            const Text(
              "Habari za Leo, Admin 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            Text(
              "Angalia muhtasari wa hali ya mazingira na dharura za usafi.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 25),

            // SEHEMU YA 1: Takwimu za Moja kwa Moja (Live Counters kutoka Firestore)
            const Text(
              "Muhtasari wa Mfumo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildLiveStatisticsGrid(),

            const SizedBox(height: 30),

            // SEHEMU YA 2: Njia za Mkato (Quick Actions zilizoboreshwa)
            const Text(
              "Usimamizi na Njia za Mkato",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildQuickActionsGrid(context),
          ],
        ),
      ),
    );
  }

  // Widget inayovuta takwimu halisi (StreamBuilder) kutoka Firestore
  Widget _buildLiveStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        // 1. Ripoti Zote Zilizopo
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('reports').snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard(
              "Ripoti za Uchafu",
              count.toString(),
              Ionicons.alert_circle,
              Colors.orange,
            );
          },
        ),

        // 2. Mapipa Yaliyofurika
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('dustbins').where('isFull', isEqualTo: true).snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard(
              "Mapipa Yaliyojaa",
              count.toString(),
              Ionicons.trash_bin,
              Colors.redAccent,
            );
          },
        ),

        // 3. Idadi ya Wakusanyaji Taka (Collectors)
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').where('role', isEqualTo: 'collector').snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard(
              "Wakusanyaji (Active)",
              count.toString(),
              Ionicons.people,
              Colors.blue,
            );
          },
        ),

        // 4. Wananchi Waliojisajili (Citizens)
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').where('role', isEqualTo: 'citizen').snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard(
              "Wananchi",
              count.toString(),
              Ionicons.person,
              Colors.green,
            );
          },
        ),
      ],
    );
  }

  // Kadi Moja ya Takwimu
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // Gridi Iliyoboreshwa ya Njia za Mkato (Sasa ina vitufe 3 vyenye kazi kamili)
  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        // 1. Dharura na Kugawa Kazi
        _buildActionCard(
          context,
          "Dharura & Ripoti",
          "Kagua na gawa kazi",
          Ionicons.notifications,
          Colors.green,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminNotification()),
            );
          },
        ),

        // 2. Kusajili Mapipa ya IoT (Imeunganishwa na RegisterBinScreen)
        _buildActionCard(
          context,
          "Sajili IoT Pipa",
          "Ongeza kifaa kipya",
          Ionicons.hardware_chip_outline,
          Colors.indigo,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterBinScreen()),
            );
          },
        ),

        // 3. Chumba cha Mawasiliano (Imeunganishwa na MoreChat)
        _buildActionCard(
          context,
          "Mawasiliano",
          "Chati na watumiaji",
          Ionicons.chatbubbles_outline,
          Colors.teal,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MoreChat()),
            );
          },
        ),
      ],
    );
  }

  // Kadi ya Njia ya Mkato (Kitufe kikubwa)
  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}