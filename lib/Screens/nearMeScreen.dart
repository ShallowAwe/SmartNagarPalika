// import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
import 'package:smart_nagarpalika/Data/dummyPlace.dart';
import 'package:smart_nagarpalika/Model/placesModel.dart';
import 'package:url_launcher/url_launcher.dart';

class NearMeScreen extends StatefulWidget {
  const NearMeScreen({super.key});

  @override
  State<NearMeScreen> createState() => _NearMeScreenState();
}

class _NearMeScreenState extends State<NearMeScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  final List<PlaceModel> _places = [];
  final Set<Marker> _markers = {};
  bool _isFetching = false;

  final List<String> _allFilters = [
    'hospital',
    'school',
    'police',
    'park',
    'gas_station',
    'fire_station',
    'bank',
    'public_toilet',
  ];

  final List<String> _selectedFilters = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInit();
  }

  Future<void> _checkPermissionAndInit() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        debugPrint("Location permission denied.");
        return;
      }
    }
    _initLocation();
  }

  // to redireect the user to the maps

  void _openInMaps(double lat, double lng, String label) async {
    final encodedLabel = Uri.encodeComponent(label);
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$encodedLabel';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint("Could not launch Google Maps.");
    }
  }

  Future<void> _initLocation() async {
    try {
      final location = await Geolocator.getCurrentPosition();
      final latLng = LatLng(location.latitude, location.longitude);
      debugPrint("Current location: $latLng");

      setState(() {
        _currentLatLng = latLng;
      });

      // _fetchNearbyPlaces(latLng.latitude, latLng.longitude, _selectedFilters.isEmpty ? _allFilters : _selectedFilters);
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _fetchNearbyPlaces(
    double lat,
    double lng,
    List<String> types,
  ) async {
    _isFetching = true;
    _places.clear();
    _markers.clear();
    setState(() {});

    // Use dummyPlaces from imported dummy_places.dart
    final filtered = dummyPlaces.where((place) {
      return types.isEmpty ||
          (place.types?.any((t) => types.contains(t)) ?? false);
    }).toList();

    for (var place in filtered) {
      _places.add(place);
      _markers.add(
        Marker(
          markerId: MarkerId(place.placeId),
          position: LatLng(place.lat, place.lng),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address,
            onTap: () async {
              OkCancelResult result = await showOkCancelAlertDialog(
                context: context,
                title: "Open in Maps",
                message: "Do you want to open in maps?",
                okLabel: "Yes",
                cancelLabel: "No",
              );

              if (result == OkCancelResult.ok) {
                _openInMaps(place.lat, place.lng, place.name);
              }
            },
          ),
          icon: await _getCustomMarkerIcon(place.types?.first ?? 'default'),
        ),
      );
    }

    _isFetching = false;
    setState(() {
      print("Current location $LatLng");
    });
  }

  // Future<void> _fetchNearbyPlaces(double lat, double lng, List<String> types) async {
  //   if (_isFetching) return;
  //   debugPrint("Fetching places for filters: $types");

  //   _isFetching = true;
  //   _places.clear();
  //   _markers.clear();
  //   final Set<String> addedPlaceIds = {};
  //   setState(() {}); // To show loader/clear map

  //   final Map<String, String> placeTypeMap = {
  //     'Hospital': 'hospital',
  //     'school': 'school',
  //     'police': 'police',
  //     'park': 'park',
  //     'gas_station': 'gas_station',
  //     'fire_station': 'fire_station',
  //     'bank': 'bank',
  //     'public_toilet': 'toilet', // Google uses 'toilet' for public toilets
  //   };

  //   for (final type in types) {
  //     final normalized = placeTypeMap[type.trim().toLowerCase()] ?? type.trim().toLowerCase();

  //     final url = Uri.parse(
  //       'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
  //       '?location=$lat,$lng'
  //       '&radius=1000'
  //       '&type=$normalized'
  //       '&key=AIzaSyDGZ_4Yiy7wqyYq-f-wyhZ4Ryxw1CgkncM'
  //     );

  //     debugPrint("Fetching for type: $type -> $normalized");
  //     debugPrint("Request URL: ${url.toString().replaceAll(RegExp(r'key=.*'), 'key=***')}"); // Hide API key in logs

  //     try {
  //       final res = await http.get(url);
  //       debugPrint("Response status for $type: ${res.statusCode}");

  //       if (res.statusCode == 200) {
  //         final data = jsonDecode(res.body);
  //         final status = data['status'];

  //         debugPrint("API Status for $type: $status");

  //         if (status == 'OK') {
  //           final results = data['results'] as List;
  //           debugPrint("Found ${results.length} places for $type");

  //           for (var item in results) {
  //             try {
  //               final place = PlaceModel.fromJson(item);
  //               if (!addedPlaceIds.contains(place.placeId)) {
  //                 _places.add(place);
  //                 addedPlaceIds.add(place.placeId);
  //                 _markers.add(
  //                   Marker(
  //                     markerId: MarkerId(place.placeId),
  //                     position: LatLng(place.lat, place.lng),
  //                     infoWindow: InfoWindow(title: place.name, snippet: place.address),
  //                     icon: await _getCustomMarkerIcon(type),
  //                   ),
  //                 );
  //               }
  //             } catch (e) {
  //               debugPrint("Error parsing place data: $e");
  //             }
  //           }
  //         } else if (status == 'ZERO_RESULTS') {
  //           debugPrint("No results found for $type");
  //         } else {
  //           debugPrint("API Error for $type: $status");
  //           if (data['error_message'] != null) {
  //             debugPrint("Error message: ${data['error_message']}");
  //           }
  //         }
  //       } else {
  //         debugPrint("HTTP Error for $type: ${res.statusCode}");
  //         debugPrint("Response body: ${res.body}");
  //       }
  //     } catch (e) {
  //       debugPrint('Exception while fetching $type: $e');
  //     }
  //   }

  //   _isFetching = false;
  //   setState(() {});
  //   debugPrint("Finished fetching. Total places found: ${_places.length}");
  // }

  Future<BitmapDescriptor> _getCustomMarkerIcon(String type) async {
    // You can customize marker icons based on type
    switch (type) {
      case 'hospital':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'school':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'police':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'park':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'gas_station':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      case 'fire_station':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case 'bank':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      case 'public_toilet':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueMagenta,
        );
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final tempSelected = [..._selectedFilters];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Select Place Type",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: _allFilters.map((type) {
                        final isSelected = tempSelected.contains(type);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              isSelected
                                  ? tempSelected.remove(type)
                                  : tempSelected.add(type);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? Colors.blue[100]
                                  : Colors.grey[200],
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _getIconForType(type),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getLabelForType(type),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.blue[700]
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempSelected.clear();
                              });
                            },
                            child: const Text("Clear All"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                _selectedFilters.clear();
                                _selectedFilters.addAll(tempSelected);
                              });

                              if (_currentLatLng != null) {
                                debugPrint(
                                  "Applying filters: $_selectedFilters",
                                );
                                _fetchNearbyPlaces(
                                  _currentLatLng!.latitude,
                                  _currentLatLng!.longitude,
                                  _selectedFilters.isEmpty
                                      ? _allFilters
                                      : _selectedFilters,
                                );
                              }
                            },
                            child: const Text("Apply Filter"),
                          ),
                        ),
                      ],
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

  String _getLabelForType(String type) {
    const labelMap = {
      'hospital': 'Hospital',
      'school': 'School',
      'police': 'Police Station',
      'fire_station': 'Fire Station',
      'bank': 'Bank',
      'park': 'Park',
      'gas_station': 'Gas Station',
      'public_toilet': 'Public Toilet',
    };

    return labelMap[type] ?? _capitalizeWords(type);
  }

  Widget _getIconForType(String type) {
    const iconMap = {
      'bank': 'lib/assets/bank.png',
      'school': 'lib/assets/School.png',
      'police': 'lib/assets/policeStation.png',
      'park': 'lib/assets/park.png',
      'gas_station': 'lib/assets/fuelStation.png',
      'hospital': 'lib/assets/hospital.png',
      'fire_station': 'lib/assets/fireStation.png',
      'public_toilet': 'lib/assets/restroom.png',
    };

    final path = iconMap[type];

    if (path != null) {
      return Image.asset(
        path,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _getDefaultIcon(type);
        },
      );
    }

    return _getDefaultIcon(type);
  }

  Widget _getDefaultIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'hospital':
        iconData = Icons.local_hospital;
        color = Colors.red;
        break;
      case 'school':
        iconData = Icons.school;
        color = Colors.blue;
        break;
      case 'police':
        iconData = Icons.local_police;
        color = Colors.indigo;
        break;
      case 'park':
        iconData = Icons.park;
        color = Colors.green;
        break;
      case 'gas_station':
        iconData = Icons.local_gas_station;
        color = Colors.orange;
        break;
      case 'fire_station':
        iconData = Icons.fire_truck;
        color = Colors.deepOrange;
        break;
      case 'bank':
        iconData = Icons.account_balance;
        color = Colors.teal;
        break;
      case 'public_toilet':
        iconData = Icons.wc;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.location_on;
        color = Colors.grey;
    }

    return Icon(iconData, size: 24, color: color);
  }

  String _capitalizeWords(String input) {
    return input
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Near Me'),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: _currentLatLng == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Getting your location..."),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                ),

                // Loading overlay
                if (_isFetching)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Finding nearby places...",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Filter button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Results count
                        if (_places.isNotEmpty && !_isFetching)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${_places.length} places found",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Filter button
                        GestureDetector(
                          onTap: _showFilterBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.filter_alt_outlined,
                                  color: _selectedFilters.isEmpty
                                      ? Colors.grey[600]
                                      : Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedFilters.isEmpty
                                      ? "Tap to Filter"
                                      : "${_selectedFilters.length} filters applied",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedFilters.isEmpty
                                        ? Colors.grey[600]
                                        : Colors.blue,
                                  ),
                                ),
                              ],
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

// class _popUpToNavigate extends StatelessWidget {
//   const _popUpToNavigate({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
         
//         ],
//       ),
//     );
//   }
// }

