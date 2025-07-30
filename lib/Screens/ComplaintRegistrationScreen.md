# ComplaintRegistrationScreen Documentation

## Overview
The `ComplaintRegistrationScreen` allows users to submit new complaints to the municipal authority. It provides a comprehensive form with image capture, location services, and category selection. The service has been enhanced with advanced image compression, robust error handling, and improved performance optimizations.

## File Location
`lib/Screens/complaintRegistrationScreen.dart`

## Class Structure
- **Class Name**: `ComplaintRegistrationScreen`
- **Type**: StatefulWidget
- **State Class**: `_ComplaintRegistrationScreenState`

## Features

### 1. Form Validation
- Comprehensive form validation using `FormValidator`
- Required field validation
- Category selection validation
- Image attachment validation

### 2. Image Capture & Management
- Camera integration for photo capture
- Support for up to 5 image attachments
- **NEW**: Advanced image compression with quality optimization
- **NEW**: Automatic file cleanup after upload
- Permission handling for camera access
- Image preview and management

### 3. Location Services
- GPS location detection
- Manual address input
- Landmark specification
- Location validation

### 4. Category Selection
- Dropdown menu for complaint categories
- Predefined municipal service categories
- Category-specific validation

### 5. Form Submission
- **ENHANCED**: Async submission with image compression
- **NEW**: Connectivity testing before upload
- **NEW**: Extended timeout handling (60 seconds)
- **NEW**: Comprehensive error logging and debugging
- Loading state management
- Success/error feedback
- Navigation to complaints list

## Dependencies

### Internal Dependencies
- `package:smart_nagarpalika/Model/coplaintModel.dart` - Complaint data model
- `package:smart_nagarpalika/Screens/ComplaintsScreen.dart` - Navigation target
- `package:smart_nagarpalika/Services/camera_service.dart` - Camera functionality
- `package:smart_nagarpalika/Services/complaintService.dart` - **ENHANCED** API service
- `package:smart_nagarpalika/utils/formValidator.dart` - Form validation
- `package:smart_nagarpalika/widgets/mapWidget.dart` - Map display

### External Dependencies
- `package:flutter/material.dart` - Flutter UI framework
- `package:geolocator/geolocator.dart` - Location services
- `package:image_picker/image_picker.dart` - Image capture
- `package:permission_handler/permission_handler.dart` - Permission management
- **NEW**: `package:flutter_image_compress/flutter_image_compress.dart` - Image compression
- **NEW**: `package:cached_network_image/cached_network_image.dart` - Image caching
- **NEW**: `package:flutter_cache_manager/flutter_cache_manager.dart` - Cache management
- `dart:io` - File operations

## State Management

### Form Controllers
- `_descriptionController` - Complaint description
- `_addressController` - Address input
- `_landmarkController` - Landmark specification

### State Variables
- `_mediaFiles` - List of captured images
- `_selectedCategory` - Selected complaint category
- `_currentLocation` - GPS coordinates
- `_isSubmitting` - Submission loading state
- `_attachments` - Image file paths

## Key Methods

### _handleFileUpload()
- Requests camera permission
- Captures image using camera service
- Validates file count limit (max 5)
- Updates state with new image

### _submitComplaint()
- **ENHANCED**: Validates form completeness with improved error handling
- Checks category selection
- **NEW**: Submits complaint with compressed images
- **NEW**: Handles connectivity issues gracefully
- **NEW**: Provides detailed error feedback
- Handles success/error states
- Navigates to complaints list

### _onLocationChanged(Position? position)
- Updates current location state
- Handles GPS coordinate changes
- Integrates with map widget

## UI Components

### Form Structure
```
Scaffold
├── AppBar
├── SingleChildScrollView
│   └── Form
│       ├── Description TextField
│       ├── Category Dropdown
│       ├── Address TextField
│       ├── Landmark TextField
│       ├── Map Widget
│       ├── Image Attachments
│       └── Submit Button
```

### Image Attachment Section
- Grid layout for image previews
- Add image button
- Image count indicator
- Remove image functionality
- **NEW**: Compression status indicators

### Map Integration
- Interactive map widget
- Current location display
- Location selection capability
- Coordinate display

## Form Validation Rules

### Description Field
- Required field
- Minimum length validation
- Maximum length limit

### Category Selection
- Must select a category
- Dropdown validation

### Address Field
- Required field
- Address format validation

### Image Attachments
- Maximum 5 images
- **ENHANCED**: File size validation with compression
- **NEW**: Format validation with fallback handling
- **NEW**: Compression quality optimization

## Permission Handling

### Camera Permission
- Requests camera access on image capture
- Handles permission denial gracefully
- Shows appropriate error messages

### Location Permission
- Requests location access
- Handles permission states
- Provides fallback options

## Error Handling

### Form Validation Errors
- Field-specific error messages
- Visual error indicators
- Form submission prevention

### Network Errors
- **ENHANCED**: Connection error handling with retry
- **NEW**: Connectivity testing before upload
- **NEW**: Detailed error logging for debugging
- User-friendly error messages

### Permission Errors
- Permission denial handling
- Alternative flow suggestions
- Clear user guidance

### Image Processing Errors
- **NEW**: Compression failure fallback
- **NEW**: File validation with error recovery
- **NEW**: Automatic cleanup on errors

## Performance Considerations

### Image Optimization
- **ENHANCED**: Advanced image compression (70% quality, 1024px max)
- **NEW**: Automatic file cleanup after upload
- **NEW**: Compression ratio monitoring
- **NEW**: Fallback to original files if compression fails
- Efficient file handling
- Memory management

### Location Services
- Efficient GPS usage
- Battery optimization
- Location caching

### Network Operations
- **NEW**: Connectivity testing before upload
- **NEW**: Extended timeout handling (60 seconds)
- **NEW**: Request size monitoring
- Implement proper loading states
- Handle connectivity issues
- Use efficient API calls
- Cache data when appropriate

## Accessibility Features

### Form Accessibility
- Proper form labels
- Screen reader support
- Keyboard navigation
- Focus management

### Visual Accessibility
- High contrast colors
- Clear error indicators
- Readable font sizes
- Touch-friendly buttons

## Future Enhancements

### Advanced Features
- Voice input for description
- Offline form saving
- Draft complaint management
- Auto-save functionality
- **PLANNED**: Real-time upload progress indicators

### Integration Improvements
- Real-time location tracking
- Address autocomplete
- Category suggestions
- **ENHANCED**: Advanced image editing capabilities
- **PLANNED**: Batch image processing

## Recent Updates (Latest Version)

### Image Compression System
- **Added**: `flutter_image_compress` dependency for efficient image processing
- **Implemented**: Automatic image compression with 70% quality and 1024px max dimensions
- **Added**: Compression ratio monitoring and logging
- **Implemented**: Fallback mechanism to original files if compression fails
- **Added**: Automatic cleanup of compressed files after upload

### Enhanced Error Handling
- **Added**: Comprehensive error logging with detailed debugging information
- **Implemented**: Connectivity testing before upload attempts
- **Added**: Extended timeout handling (60 seconds) for large file uploads
- **Implemented**: Request size monitoring and validation
- **Added**: Graceful error recovery with user-friendly messages

### Performance Optimizations
- **Added**: Request field validation and monitoring
- **Implemented**: File existence and size validation
- **Added**: Memory-efficient file processing
- **Implemented**: Automatic resource cleanup

### Debugging and Monitoring
- **Added**: Detailed console logging for all upload steps
- **Implemented**: Request and response monitoring
- **Added**: File processing status tracking
- **Implemented**: Error categorization and reporting

## Related Files
- `lib/Model/coplaintModel.dart` - Data structure
- `lib/Services/camera_service.dart` - Camera operations
- `lib/Services/complaintService.dart` - **ENHANCED** API integration with compression
- `lib/utils/formValidator.dart` - Validation logic
- `lib/widgets/mapWidget.dart` - Map functionality

## Usage Examples

### Basic Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ComplaintRegistrationScreen(),
  ),
);
```

### Form Validation
```dart
if (!_formKey.currentState!.validate()) {
  return;
}
```

### Image Capture with Compression
```dart
final XFile? pickedFile = await CameraService().pickFromCamera();
if (pickedFile != null) {
  setState(() {
    _mediaFiles!.add(pickedFile);
  });
}
```

### Enhanced Complaint Submission
```dart
// The service now automatically handles:
// - Image compression
// - Connectivity testing
// - Extended timeouts
// - Error recovery
// - File cleanup
await ComplaintService.instance.submitComplaint(complaint, username);
```

## Troubleshooting

### Common Issues
1. **Camera not working**: Check permission settings
2. **Location not detected**: Verify GPS permissions
3. **Form submission fails**: Check network connectivity
4. **Image upload errors**: Verify file size and format
5. **NEW**: **Compression errors**: Check available storage space
6. **NEW**: **Timeout errors**: Verify network stability

### Debug Tips
- **ENHANCED**: Enable debug logging for detailed error information
- **NEW**: Monitor compression ratios in console output
- **NEW**: Check connectivity test results
- Test with different image sizes and formats
- Verify API endpoint configuration
- Check permission states in device settings
- **NEW**: Monitor file cleanup operations

### Performance Optimization
- **NEW**: Monitor compression ratios for optimal quality/size balance
- **NEW**: Check network connectivity before large uploads
- **NEW**: Verify available storage space for temporary files
- **NEW**: Monitor upload timeout settings for slow connections

---

**Last Updated**: December 2024  
**Version**: 2.0.0  
**Maintainer**: Smart Nagarpalika Development Team 