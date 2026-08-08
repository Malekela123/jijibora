import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ionicons/ionicons.dart';

class UserLocation extends StatefulWidget {
  const UserLocation({super.key});

  @override
  State<UserLocation> createState() => _UserLocationState();
}

class _UserLocationState extends State<UserLocation> {

  final LatLng _initialPosition = const LatLng(-6.7924, 39.2083);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ukurasa wa Ramani",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 60,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.eco_clean_mobile_app',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(-6.7924, 39.2083),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Ionicons.location,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),

                  Marker(
                    point: const LatLng(-6.7950, 39.2120),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Ionicons.location,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Ionicons.location,
                    color: Color(0xFF418E3C),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Angalia maeneo yenye madumu ya taka ya EcoClean karibu nawe.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}