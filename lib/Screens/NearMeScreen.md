# NearMeScreen Documentation

## Overview
The `NearMeScreen` provides users with a map-based interface to discover nearby municipal facilities and services. It integrates Google Maps with location services to show points of interest around the user's current location.

## File Location
`lib/Screens/nearMeScreen.dart`

## Class Structure
- **Class Name**: `NearMeScreen`
- **Type**: StatefulWidget
- **State Class**: `_NearMeScreenState`

## Features

### 1. Interactive Map Display
- Google Maps integration
- Real-time location tracking
- Custom markers for different facility types
- Map controls and zoom functionality

### 2. Location Services
- GPS location detection
- Permission handling for location access
- Current location display
- Location-based facility search

### 3. Facility Categories
- **Healthcare**: Hospitals, clinics
- **Education**: Schools, colleges
- **Security**: Police stations
- **Recreation**: Parks, playgrounds
- **Transportation**: Gas stations
- **Emergency**: Fire stations
- **Financial**: Banks, ATMs
- **Public Services**: Public toilets

### 4. Filtering System
- Multi-category filtering
- Dynamic filter updates
- Visual filter indicators
- All/none filter options

### 5. Navigation Integration
- External map app integration
- Google Maps deep linking
- Route planning capabilities
- Location sharing

## Dependencies

### Internal Dependencies
- `package:smart_nagarpalika/Data/dummyPlace.dart` - Sample place data
- `package:smart_nagarpalika/Model/placesModel.dart` - Place data model

### External Dependencies
- `package:flutter/material.dart` - Flutter UI framework
- `package:adaptive_dialog/adaptive_dialog.dart` - Platform-adaptive dialogs
- `package:geolocator/geolocator.dart` - Location services
- `package:google_maps_flutter/google_maps_flutter.dart` - Google Maps
- `package:url_launcher/url_launcher.dart` - URL handling

## State Management

### Map State
- `_mapController` - Google Maps controller
- `_currentLatLng` - Current user location
- `_markers` - Map markers set
- `_places` - List of nearby places

### Filter State
- `_allFilters` - Available filter categories
- `_selectedFilters` - Currently active filters
- `_isFetching` - Loading state indicator

## Key Methods

### _checkPermissionAndInit()
- Checks location permission status
- Requests permission if needed
- Initializes location services
- Handles permission denial gracefully

### _initLocation()
- Gets current GPS position
- Updates map center
- Triggers nearby place search
- Handles location errors

### _fetchNearbyPlaces(double lat, double lng, List<String> types)
- Searches for places by category
- Creates map markers
- Updates place list
- Handles search errors

### _openInMaps(double lat, double lng, String label)
- Opens external map application
- Uses Google Maps deep linking
- Handles URL launching errors
- Provides fallback options

## UI Components

### Map Interface
```
Scaffold
├── AppBar (with filter controls)
├── GoogleMap
│   ├── Current Location Marker
│   ├── Facility Markers
│   └── Map Controls
└── Filter Panel
    ├── Category Filters
    └── Search Results
```

### Filter Panel
- Horizontal scrollable filter chips
- Visual selection indicators
- Category icons and labels
- Filter count display

### Marker System
- Different marker colors per category
- Custom marker icons
- Info windows with place details
- Tap-to-navigate functionality

## Location Services

### Permission Handling
- **Location Permission**: Requests location access
- **Permission States**: Handles granted/denied/restricted
- **Fallback Options**: Provides manual location input
- **User Guidance**: Clear permission request messages

### GPS Integration
- Real-time location updates
- Location accuracy settings
- Battery optimization
- Location caching

## Map Configuration

### Google Maps Setup
- API key configuration
- Map styling options
- Zoom level management
- Map type selection

### Marker Management
- Custom marker creation
- Marker clustering (future)
- Marker animation
- Info window customization

## Filter System

### Available Categories
1. **hospital** - Healthcare facilities
2. **school** - Educational institutions
3. **police** - Law enforcement
4. **park** - Recreational areas
5. **gas_station** - Fuel stations
6. **fire_station** - Emergency services
7. **bank** - Financial institutions
8. **public_toilet** - Public facilities

### Filter Logic
- Multi-select filtering
- Dynamic marker updates
- Search result filtering
- Performance optimization

## Navigation Features

### External Map Integration
- Google Maps app launching
- Deep link URL construction
- Route planning integration
- Location sharing capabilities

### URL Handling
- Platform-specific URL schemes
- Fallback web browser opening
- Error handling for unsupported apps
- User feedback for navigation actions

## Performance Optimizations

### Map Performance
- Efficient marker rendering
- Viewport-based loading
- Memory management
- Battery optimization

### Location Services
- Location request throttling
- GPS accuracy optimization
- Background location handling
- Location data caching

## Error Handling

### Location Errors
- GPS signal loss handling
- Permission denial recovery
- Location timeout handling
- Network connectivity issues

### Map Errors
- API key validation
- Map loading failures
- Marker rendering errors
- External app launch failures

## Accessibility Features

### Map Accessibility
- Screen reader support
- Voice navigation
- High contrast mode
- Touch target sizing

### Filter Accessibility
- Keyboard navigation
- Focus management
- Clear visual indicators
- Alternative text for icons

## Future Enhancements

### Advanced Features
- Real-time facility status
- User reviews and ratings
- Facility details and photos
- Offline map support

### Integration Improvements
- Public transport integration
- Facility booking system
- Emergency contact integration
- Social sharing features

## Related Files
- `lib/Data/dummyPlace.dart` - Sample data
- `lib/Model/placesModel.dart` - Data models
- `lib/Services/location_service.dart` - Location utilities

## Usage Examples

### Basic Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const NearMeScreen()),
);
```

### Location Permission Check
```dart
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}
```

### External Map Launch
```dart
final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
if (await canLaunchUrl(Uri.parse(url))) {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
```

## Troubleshooting

### Common Issues
1. **Map not loading**: Check Google Maps API key
2. **Location not detected**: Verify GPS permissions
3. **Markers not showing**: Check filter selection
4. **External maps not opening**: Verify URL launcher configuration

### Debug Tips
- Enable location debugging logs
- Test with different GPS accuracy settings
- Verify API key permissions
- Check network connectivity for place data 