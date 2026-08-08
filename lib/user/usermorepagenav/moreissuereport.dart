import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart'; // Imeongezwa kwa ajili ya GPS
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:latlong2/latlong.dart';

class MoreIssueReport extends StatefulWidget {
  const MoreIssueReport({super.key});

  @override
  State<MoreIssueReport> createState() => _MoreIssueReportState();
}

class _MoreIssueReportState extends State<MoreIssueReport> {
  final _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final MapController _mapController = MapController();

  // Eneo la kuanzia (Default: Dodoma) litabadilika GPS ikisoma
  LatLng _pickedLocation = const LatLng(-6.1731, 35.7419); 
  
  XFile? _mediaFile; 
  bool _isVideo = false;
  bool _isLoading = false;
  bool _isGettingGPS = false;

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Inatafuta eneo la mtumiaji akifungua tu ukurasa
  }

  // Function ya kuomba ruhusa ya GPS na kupata eneo la sasa la mtumiaji
  Future<void> _determinePosition() async {
    setState(() => _isGettingGPS = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _pickedLocation = currentLatLng;
      });

      // Kusogeza kamera ya ramani hadi eneo la mtumiaji la GPS
      _mapController.move(currentLatLng, 16.0);
    } catch (e) {
      debugPrint("Mchakato wa GPS umeshindwa: $e");
    } finally {
      setState(() => _isGettingGPS = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (selected != null) {
      setState(() {
        _mediaFile = selected;
        _isVideo = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? selected = await _picker.pickVideo(source: ImageSource.gallery);
    if (selected != null) {
      setState(() {
        _mediaFile = selected;
        _isVideo = true;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tafadhali andika maelezo ya tatizo!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? currentUserUid = _auth.currentUser?.uid;

      await _firestore.collection('reports').add({
        'userId': currentUserUid,
        'description': _descriptionController.text.trim(),
        'location': GeoPoint(_pickedLocation.latitude, _pickedLocation.longitude),
        'mediaType': _mediaFile != null ? (_isVideo ? 'video' : 'image') : 'none',
        'status': 'Inasubiri',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text("Ripoti imetumwa na eneo la ramani limehifadhiwa!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Imeshindwa kutuma: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Ripoti Tatizo la Uchafu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          if (_isGettingGPS)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green))),
            )
          else
            IconButton(
              icon: const Icon(Ionicons.locate_outline, color: Colors.green),
              onPressed: _determinePosition,
              tooltip: "Tafuta nipo wapi",
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ramani ya Uchaguzi wa Eneo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Sogeza ramani kuweka alama ya eneo:",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13),
                ),
                Text(
                  "Lat: ${_pickedLocation.latitude.toStringAsFixed(4)}, Lon: ${_pickedLocation.longitude.toStringAsFixed(4)}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _pickedLocation,
                        initialZoom: 15.0,
                        // Imerekebishwa kutoka MapPosition kwenda MapCamera kwa ajili ya v6.0.0+
                        onPositionChanged: (MapCamera camera, bool hasGesture) {
                          if (hasGesture && camera.center != null) {
                            setState(() {
                              _pickedLocation = camera.center;
                            });
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.eco_clean_mobile_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _pickedLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Ionicons.location,
                                color: Colors.red,
                                size: 38,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Kitufe kidogo cha dharura juu ya ramani kurejesha GPS
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: FloatingActionButton.small(
                        heroTag: "gps_btn",
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        onPressed: _determinePosition,
                        child: const Icon(Ionicons.locate),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. TextField ya Maelezo
            const Text("Maelezo ya Tatizo:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Eleza kwa ufupi mfano: Kuna dampo lisilo rasmi linaanza kutengenezwa hapa...",
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green)),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Vitufe vya Kupakia Ushahidi
            const Text("Ongeza Ushahidi (Picha/Video):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Ionicons.image_outline, size: 18),
                      label: const Text("Pakia Picha"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue[800],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Ionicons.videocam_outline, size: 18),
                      label: const Text("Pakia Video"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[50],
                        foregroundColor: Colors.orange[800],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Muonekano wa faili lililochaguliwa (Preview File Widget)
            if (_mediaFile != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(_isVideo ? Ionicons.film_outline : Ionicons.image_outline, color: Colors.green, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        kIsWeb ? "Ushahidi tayari umepakiwa kikamilifu" : _mediaFile!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                       style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Ionicons.close_circle, color: Colors.redAccent, size: 22),
                      onPressed: () => setState(() => _mediaFile = null),
                    )
                  ],
                ),
              ),
            const SizedBox(height: 30),

            // 4. Kitufe cha Kutuma Ripoti (Submit Button)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32), // Rangi ya kijani ya giza (Environmental Green)
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("TUMA TAARIFA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}