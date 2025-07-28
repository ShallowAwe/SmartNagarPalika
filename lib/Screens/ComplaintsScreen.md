# ComplaintsScreen Documentation

## Overview
The `ComplaintsScreen` displays a list of user complaints with their current status, allowing users to view complaint details, track progress, and perform actions based on complaint status.

## File Location
`lib/Screens/ComplaintsScreen.dart`

## Class Structure
- **Class Name**: `Complaintsscreen`
- **Type**: StatefulWidget
- **State Class**: `_ComplaintsscreenState`

## Features

### 1. Complaint List Display
- Shows all complaints for the current user
- Displays complaint cards with key information
- Handles empty state with helpful messaging

### 2. Status Management
- **Status Types**: Pending, In Progress, Resolved, Rejected
- **Color Coding**: Each status has distinct colors
- **Icons**: Status-specific icons for visual identification
- **Normalization**: Handles various status formats

### 3. Complaint Details Popup
- Comprehensive complaint information display
- Image attachments with caching
- Action buttons based on complaint status
- Formatted date display

### 4. Image Handling
- Cached network images with error handling
- Basic authentication for image access
- Placeholder and error states
- Support for multiple image attachments

### 5. Status-Based Actions
- **Pending**: Edit and Cancel options
- **Resolved**: Rate & Review functionality
- **Other Statuses**: Track Progress option

## Dependencies

### Internal Dependencies
- `package:smart_nagarpalika/Model/coplaintModel.dart` - Complaint data model
- `package:smart_nagarpalika/Screens/complaintRegistrationScreen.dart` - New complaint creation
- `package:smart_nagarpalika/Services/complaintService.dart` - Complaint API service

### External Dependencies
- `package:flutter/material.dart` - Flutter UI framework
- `package:cached_network_image/cached_network_image.dart` - Image caching
- `package:flutter_cache_manager/flutter_cache_manager.dart` - Cache management
- `dart:convert` - Base64 encoding for authentication
- `dart:io` - File operations
- `dart:math` - Random number generation

## State Management
- Uses `FutureBuilder` for async complaint loading
- Local state for UI interactions
- Future-based complaint data fetching

## Key Methods

### _normalizeStatus(String? status)
- Normalizes complaint status strings
- Handles various status formats
- Returns lowercase status for consistent comparison

### _getStatusColor(String? status)
- Returns appropriate color for each status
- **Pending**: Orange
- **In Progress**: Blue
- **Resolved**: Green
- **Rejected**: Red
- **Default**: Grey

### _getStatusIcon(String? status)
- Returns appropriate icon for each status
- **Pending**: `Icons.schedule`
- **In Progress**: `Icons.hourglass_empty`
- **Resolved**: `Icons.check_circle`
- **Rejected**: `Icons.cancel`
- **Default**: `Icons.help`

### buildComplaintCard(ComplaintModel complaint)
- Creates individual complaint card widgets
- Handles image preview with error states
- Displays status badges and key information

### _showComplaintDetailsPopup(ComplaintModel complaint, String? status)
- Shows detailed complaint information in a dialog
- Displays all complaint fields and attachments
- Provides status-appropriate action buttons

## UI Components

### Complaint Card Structure
```
Card
├── Row
│   ├── Image Preview (60x60)
│   ├── SizedBox (12px spacing)
│   └── Expanded Column
│       ├── Date and Status Badge Row
│       ├── Description Text
│       ├── Location Row
│       └── Category Row
```

### Status Badge Design
- Rounded container with status color
- Icon and text combination
- Semi-transparent background
- Colored border

### Details Popup Structure
```
Dialog
├── Header (Status-based styling)
├── Content
│   ├── Complaint Details
│   ├── Description Box
│   ├── Image Attachments
│   └── Action Buttons
```

## Error Handling

### Image Loading Errors
- Displays broken image icon for failed loads
- Logs error details for debugging
- Graceful fallback to placeholder

### Network Errors
- Shows error message in FutureBuilder
- Handles connection state changes
- Provides retry functionality

### Empty States
- Custom empty state with helpful messaging
- Call-to-action button for new complaints
- Clear user guidance

## Authentication
- Uses Basic Authentication for image access
- Credentials: username='user1', password='user1'
- Base64 encoded authorization headers

## Image Caching
- Custom cache manager configuration
- 1-day stale period for images
- Efficient memory management
- Network image optimization

## Performance Optimizations
- Cached network images reduce bandwidth
- Efficient list building with ListView.builder
- Minimal state updates
- Optimized image loading

## Accessibility Features
- Clear visual status indicators
- Proper contrast ratios
- Touch-friendly card sizes
- Screen reader compatible text

## Future Enhancements
- Real-time status updates
- Push notifications for status changes
- Offline complaint viewing
- Advanced filtering and sorting
- Complaint history tracking
- Export functionality

## Related Files
- `lib/Model/coplaintModel.dart` - Complaint data structure
- `lib/Services/complaintService.dart` - API service implementation
- `lib/Screens/complaintRegistrationScreen.dart` - Complaint creation
- `lib/widgets/mapWidget.dart` - Location display (if used)

## Usage Examples

### Basic Usage
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const Complaintsscreen()),
);
```

### Status Color Usage
```dart
Color statusColor = _getStatusColor(complaint.status);
Container(
  color: statusColor.withAlpha(25),
  child: Text(complaint.status),
)
```

## Troubleshooting

### Common Issues
1. **Images not loading**: Check authentication credentials
2. **Status not displaying**: Verify status normalization
3. **Empty list**: Check API service configuration
4. **Performance issues**: Monitor image cache usage 