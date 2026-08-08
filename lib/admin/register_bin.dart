import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:latlong2/latlong.dart'; 

class RegisterBinScreen extends StatefulWidget {
  const RegisterBinScreen({super.key});

  @override
  State<RegisterBinScreen> createState() => _RegisterBinScreenState();
}

class _RegisterBinScreenState extends State<RegisterBinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _binIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  
  final _latController = TextEditingController(text: "-6.1994");
  final _lonController = TextEditingController(text: "35.7878");
  
  final MapController _mapController = MapController();
  bool _isLoading = false;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  static const LatLng _initialLocation = LatLng(-6.1994, 35.7878);

  // Kazi ya kutafuta eneo kupitia OpenStreetMap Nominatim API
  Future<void> _searchArea(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1');

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'eco_clean_mobile_app',
      });

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Hitilafu ya utafutaji: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  // Kazi ya kusogeza ramani kwenda eneo lililochaguliwa
  void _moveToLocation(double lat, double lon, String displayName) {
    final targetLatLng = LatLng(lat, lon);
    
    _mapController.move(targetLatLng, 16.0);
    
    setState(() {
      _latController.text = lat.toStringAsFixed(6);
      _lonController.text = lon.toStringAsFixed(6);
      _nameController.text = displayName.split(',')[0]; 
      _searchResults = []; 
      _searchController.clear(); 
    });
    FocusScope.of(context).unfocus(); 
  }

  @override
  void dispose() {
    _binIdController.dispose();
    _nameController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _registerBin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      double lat = double.parse(_latController.text.trim());
      double lon = double.parse(_lonController.text.trim());

      await FirebaseFirestore.instance
          .collection('dustbins')
          .doc(_binIdController.text.trim())
          .set({
        'binId': _binIdController.text.trim(),
        'locationName': _nameController.text.trim(),
        'location': GeoPoint(lat, lon), 
        'fillLevel': 0, 
        'isFull': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pipa la IoT limesajiliwa kikamilifu!"), backgroundColor: Colors.green),
        );
        _formKey.currentState!.reset();
        
        setState(() {
          _latController.text = "-6.1994";
          _lonController.text = "35.7878";
        });
        _mapController.move(_initialLocation, 15.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Uandishi umeshindwa: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Sajili Pipa la IoT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar ya Ramani
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Tafuta eneo (Mfano: Dodoma, Chamwino...)",
                    prefixIcon: const Icon(Ionicons.search_outline, color: Colors.grey),
                    suffixIcon: _isSearching 
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : _searchController.text.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Ionicons.close_circle_outline),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchResults = []);
                                },
                              )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) => _searchArea(value),
                ),
              ),

            // 2. Orodha ya Matokeo ya Utafutaji (Dropdown ya matokeo yenye BoxConstraints)
if (_searchResults.isNotEmpty)
  Container(
    margin: const EdgeInsets.only(top: 5),
    // HAPA NDIPO PALIPOKUWA NA KOSA: Lazima iwe ndani ya constraints
    constraints: const BoxConstraints(
      maxHeight: 200,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        return ListTile(
          leading: const Icon(Ionicons.location_outline, color: Colors.green),
          title: Text(place['display_name'], style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () {
            double lat = double.parse(place['lat']);
            double lon = double.parse(place['lon']);
            _moveToLocation(lat, lon, place['display_name']);
          },
        );
      },
    ),
  ),
              const SizedBox(height: 15),

              // 3. Ramani yenyewe
              Container(
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _initialLocation,
                          initialZoom: 15.0,
                          onMapEvent: (event) {
                            if (event is MapEventMoveEnd) {
                              setState(() {
                                _latController.text = event.camera.center.latitude.toStringAsFixed(6);
                                _lonController.text = event.camera.center.longitude.toStringAsFixed(6);
                              });
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.eco_clean_mobile_app',
                          ),
                        ],
                      ),
                      const IgnorePointer(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 35), 
                            child: Icon(
                              Ionicons.location,
                              color: Colors.redAccent,
                              size: 42,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 4. Sehemu za fomu za uandishi
              TextFormField(
                controller: _binIdController,
                decoration: InputDecoration(
                  labelText: "ID ya Pipa (Mfano: bin_001)",
                  prefixIcon: const Icon(Ionicons.hardware_chip_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => val!.isEmpty ? "Weka ID ya kifaa" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Jina la Eneo lililopo",
                  prefixIcon: const Icon(Ionicons.trail_sign_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => val!.isEmpty ? "Weka jina la eneo" : null,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      readOnly: true, 
                      decoration: InputDecoration(
                        labelText: "Latitude",
                        prefixIcon: const Icon(Ionicons.compass_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lonController,
                      readOnly: true, 
                      decoration: InputDecoration(
                        labelText: "Longitude",
                        prefixIcon: const Icon(Ionicons.compass_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerBin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Kamilisha Usajili", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}