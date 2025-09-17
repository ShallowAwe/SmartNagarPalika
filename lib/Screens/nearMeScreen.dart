import 'dart:math';
import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:smart_nagarpalika/Model/placesModel.dart';
import 'package:smart_nagarpalika/provider/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NearMeScreen extends ConsumerStatefulWidget {
  const NearMeScreen({super.key});

  @override
  ConsumerState<NearMeScreen> createState() => _NearMeScreenState();
}

class _NearMeScreenState extends ConsumerState<NearMeScreen> {
  late final String username;
  late final String password;

  @override
  void initState() {
    super.initState();

    // Use addPostFrameCallback to ensure widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);

      if (authState != null) {
        username = authState.username;
        password = authState.password;

        _checkPermissionAndInit();
        _fetchCategories();
      } else {
        debugPrint("Auth state is null! Cannot fetch data.");
        // You might want to redirect to login or show an error
      }
    });
  }

  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  final List<PlaceModel> _places = [];
  final Set<Marker> _markers = {};
  bool _isFetching = false;
  List<CategoryModel> _categories = [];

  final String _placesApiUrl = 'http://192.168.1.34:8080/citizen/locations';
  final String _categoriesApiUrl =
      'http://192.168.1.34:8080/citizen/categories';

  final List<String> _selectedFilters = [];

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(_categoriesApiUrl),
        headers: {
          "Authorization":
              "Basic ${base64Encode(utf8.encode('$username:$password'))}",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _categories = data
              .map((json) => CategoryModel.fromJson(json))
              .toList();
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      // You might want to show an error message to the user
    }
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

      // _fetchNearbyPlaces();
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    if (_currentLatLng == null) return;

    setState(() {
      _isFetching = true;
      _places.clear();
      _markers.clear();
    });

    try {
      // Fetch all places from your API
      final response = await http.get(
        Uri.parse(_placesApiUrl),
        headers: {
          "Authorization":
              "Basic ${base64Encode(utf8.encode('$username:$password'))}",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allPlaces = data
            .map((json) => PlaceModel.fromJson(json))
            .toList();

        // Filter places based on selected categories
        final filteredPlaces = _selectedFilters.isEmpty
            ? allPlaces
            : allPlaces
                  .where(
                    (place) => _selectedFilters.contains(
                      place.categoryName.toLowerCase(),
                    ),
                  )
                  .toList();

        // Calculate distance and sort by proximity to current location
        filteredPlaces.sort((a, b) {
          final distanceA = _calculateDistance(
            _currentLatLng!.latitude,
            _currentLatLng!.longitude,
            a.latitude,
            a.longitude,
          );
          final distanceB = _calculateDistance(
            _currentLatLng!.latitude,
            _currentLatLng!.longitude,
            b.latitude,
            b.longitude,
          );
          return distanceA.compareTo(distanceB);
        });

        for (var place in filteredPlaces) {
          _places.add(place);
          _markers.add(
            Marker(
              markerId: MarkerId(place.name),
              position: LatLng(place.latitude, place.longitude),
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
                    _openInMaps(place.latitude, place.longitude, place.name);
                  }
                },
              ),
              icon: await _getCustomMarkerIcon(
                place.categoryName.toLowerCase(),
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      debugPrint("Error fetching places: $e");
      // You might want to show an error message to the user
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  // Calculate distance between two coordinates in kilometers using the Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert degrees to radians
    double toRadians(double degrees) => degrees * (pi / 180.0);

    double dLat = toRadians(lat2 - lat1);
    double dLon = toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(toRadians(lat1)) *
            cos(toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  Future<BitmapDescriptor> _getCustomMarkerIcon(String category) async {
    // Map your category names to marker colors
    switch (category) {
      case 'hospital':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'bank':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      // Add more cases for your categories
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
                      children: _categories.map((category) {
                        final isSelected = tempSelected.contains(
                          category.name.toLowerCase(),
                        );
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              isSelected
                                  ? tempSelected.remove(
                                      category.name.toLowerCase(),
                                    )
                                  : tempSelected.add(
                                      category.name.toLowerCase(),
                                    );
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
                                // You can display category image here if available
                                Image.network(
                                  category.imageUrl,
                                  headers: {
                                    "Authorization":
                                        "Basic ${base64Encode(utf8.encode('$username:$password'))}",
                                  },
                                  width: 24,
                                  height: 24,
                                  // errorBuilder: (context, error, stackTrace) {
                                  //   return _getDefaultIcon(
                                  //     category.name.toLowerCase(),
                                  //   );
                                  // },
                                ),
                                // _getDefaultIcon(category.name.toLowerCase()),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    category.name,
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
                              // Optional: apply immediately and refresh places
                              setState(() {
                                _selectedFilters.clear();
                                _fetchNearbyPlaces(); // refresh based on empty filter
                              });
                              Navigator.pop(context); // close bottom sheet
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
                              _fetchNearbyPlaces();
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

  // Widget _getDefaultIcon(String category) {
  //   IconData iconData;
  //   Color color;

  //   switch (category) {
  //     case 'hospital':
  //       iconData = Icons.local_hospital;
  //       color = Colors.red;
  //       break;
  //     case 'bank':
  //       iconData = Icons.account_balance;
  //       color = Colors.teal;
  //       break;
  //     // Add more cases for your categories
  //     default:
  //       iconData = Icons.location_on;
  //       color = Colors.grey;
  //   }

  //   return Icon(iconData, size: 24, color: color);
  // }

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

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
