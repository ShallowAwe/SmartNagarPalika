# ComplaintRegistrationScreen Documentation

## Overview
The `ComplaintRegistrationScreen` allows users to submit new complaints to the municipal authority. It provides a comprehensive form with image capture, location services, and category selection.

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
- Async submission to backend service
- Loading state management
- Success/error feedback
- Navigation to complaints list

## Dependencies

### Internal Dependencies
- `package:smart_nagarpalika/Model/coplaintModel.dart` - Complaint data model
- `package:smart_nagarpalika/Screens/ComplaintsScreen.dart` - Navigation target
- `package:smart_nagarpalika/Services/camera_service.dart` - Camera functionality
- `package:smart_nagarpalika/Services/complaintService.dart` - API service
- `package:smart_nagarpalika/utils/formValidator.dart` - Form validation
- `package:smart_nagarpalika/widgets/mapWidget.dart` - Map display

### External Dependencies
- `package:flutter/material.dart` - Flutter UI framework
- `package:geolocator/geolocator.dart` - Location services
- `package:image_picker/image_picker.dart` - Image capture
- `package:permission_handler/permission_handler.dart` - Permission management
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
- Validates form completeness
- Checks category selection
- Submits complaint to backend
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
- File size validation
- Format validation

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
- Connection error handling
- Retry functionality
- User-friendly error messages

### Permission Errors
- Permission denial handling
- Alternative flow suggestions
- Clear user guidance

## Performance Considerations

### Image Optimization
- Compressed image uploads
- Efficient file handling
- Memory management

### Location Services
- Efficient GPS usage
- Battery optimization
- Location caching

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

### Integration Improvements
- Real-time location tracking
- Address autocomplete
- Category suggestions
- Image editing capabilities

## Related Files
- `lib/Model/coplaintModel.dart` - Data structure
- `lib/Services/camera_service.dart` - Camera operations
- `lib/Services/complaintService.dart` - API integration
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

### Image Capture
```dart
final XFile? pickedFile = await CameraService().pickFromCamera();
if (pickedFile != null) {
  setState(() {
    _mediaFiles!.add(pickedFile);
  });
}
```

## Troubleshooting

### Common Issues
1. **Camera not working**: Check permission settings
2. **Location not detected**: Verify GPS permissions
3. **Form submission fails**: Check network connectivity
4. **Image upload errors**: Verify file size and format

### Debug Tips
- Enable debug logging for detailed error information
- Test with different image sizes and formats
- Verify API endpoint configuration
- Check permission states in device settings 