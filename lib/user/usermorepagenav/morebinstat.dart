import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ionicons/ionicons.dart';

class MoreBinStat extends StatefulWidget {
  const MoreBinStat({super.key});

  @override
  State<MoreBinStat> createState() => _MoreBinStatState();
}

class _MoreBinStatState extends State<MoreBinStat> {
  // Orodha ya mapipa ya majaribio (Hapa baadaye utaunganisha na IoT/Firebase kupata data ya uhalisia)
  final List<Map<String, dynamic>> _bins = [
    {
      "name": "Pipa Kuu la Kampasi (A)",
      "location": "Karibu na Cafeteria",
      "fillLevel": 0.35, // 35% limejaa
      "type": "Plastiki pekee",
    },
    {
      "name": "Pipa la Hosteli (B)",
      "location": "Block Block C Entrance",
      "fillLevel": 0.85, // 85% limejaa (Linaelekea kujaa)
      "type": "Taka Mchanganyiko",
    },
    {
      "name": "Pipa la Maktaba (C)",
      "location": "Nje ya Jengo la IT",
      "fillLevel": 0.95, // 95% limejaa (Limejaa!)
      "type": "Karatasi pekee",
    },
    {
      "name": "Pipa la Ofisi za Utawala",
      "location": "Main Administration Block",
      "fillLevel": 0.12, // 12% limejaa
      "type": "E-Waste / Betri",
    }
  ];

  // Kazi ya kuchagua rangi kulingana na kiwango cha ujazo wa pipa
  Color _getBinColor(double level) {
    if (level >= 0.85) {
      return Colors.redAccent; // Limejaa au kimekaribia sana
    } else if (level >= 0.60) {
      return Colors.orange; // Kiwango cha kati
    } else {
      return const Color(0xFF418E3C); // Nafasi bado ipo ya kutosha (Kijani)
    }
  }

  // Kazi ya kutoa ujumbe wa hali ya pipa
  String _getBinStatusText(double level) {
    if (level >= 0.90) {
      return "Limejaa kabisa (Tafadhali usitumie)";
    } else if (level >= 0.75) {
      return "Linakaribia kujaa";
    } else {
      return "Lina nafasi (Unaweza kutupa)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bin Status",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 60,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Hapa baadaye utaweka function ya kuvuta data mpya kutoka Firebase/Database
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Maelezo mafupi juu ya rangi zilizopo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusLegend("Safi", const Color(0xFF418E3C)),
                  _buildStatusLegend("Inajaa", Colors.orange),
                  _buildStatusLegend("Imejaa", Colors.redAccent),
                ],
              ),
              const SizedBox(height: 25),
              
              const Text(
                "Hali ya Mapipa ya Karibu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Orodha ya mapipa
              Expanded(
                child: ListView.builder(
                  itemCount: _bins.length,
                  itemBuilder: (context, index) {
                    final bin = _bins[index];
                    final double percentage = bin['fillLevel'] * 100;
                    final Color statusColor = _getBinColor(bin['fillLevel']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                                Row(
                                  children: [
                                    Icon(
                                      Ionicons.trash_outline, 
                                      color: statusColor,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bin['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          bin['location'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Asilimia ya ujazo
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${percentage.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            
                            // Mstari wa kuonesha ujazo (Progress Bar)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: bin['fillLevel'],
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                minHeight: 10,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Aina ya Taka na Hali ya sasa ya neno
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Aina: ${bin['type']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _getBinStatusText(bin['fillLevel']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kijenzi cha vijarida vya maelezo ya rangi za juu (Legends)
  Widget _buildStatusLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      ],
    );
  }
}