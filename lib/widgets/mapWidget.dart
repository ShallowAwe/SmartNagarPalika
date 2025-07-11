import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_nagarpalika/Services/location_service.dart';

class MapWidget extends StatefulWidget {
  final double height;
  final Function(Position?)? onLocationChanged;
  final bool showMyLocationButton;
  final bool showZoomControls;
  final double initialZoom;

  const MapWidget({
    super.key,
    this.height = 200,
    this.onLocationChanged,
    this.showMyLocationButton = true,
    this.showZoomControls = false,
    this.initialZoom = 16.0,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  Set<Marker> _markers = {};
  String? _locationError;

  final LocationService _locationService = LocationService.instance;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final result = await _locationService.getCurrentLocation();

    if (!mounted) return;

    setState(() {
      _isLoadingLocation = false;

      if (result.isSuccess) {
        _currentPosition = result.position;
        _createMarker(_currentPosition!.latitude, _currentPosition!.longitude);
        widget.onLocationChanged?.call(_currentPosition);
      } else {
        _locationError = result.error;
      }
    });
  }

  void _createMarker(double latitude, double longitude) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: LatLng(latitude, longitude),
        infoWindow: const InfoWindow(
          title: 'Selected Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _buildMapContent(),
      ),
    );
  }

  Widget _buildMapContent() {
    if (_isLoadingLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Fetching your location...'),
          ],
        ),
      );
    }

    if (_locationError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 40, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                _locationError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _initializeLocation,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Location not available'),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        zoom: widget.initialZoom,
      ),
      markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: widget.showMyLocationButton,
      mapType: MapType.normal,
      zoomControlsEnabled: widget.showZoomControls,
      onTap: (LatLng latLng) {
        _createMarker(latLng.latitude, latLng.longitude);

        final selectedPosition = Position(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        widget.onLocationChanged?.call(selectedPosition);
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
