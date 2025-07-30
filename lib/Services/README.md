# Services Logger Implementation

This directory contains all the service files with proper logging implementation using the `logger` package.

## Logger Service (`logger_service.dart`)

The `LoggerService` is a centralized logging service that provides consistent logging across all services with different log levels and proper formatting.

### Features

- **Singleton Pattern**: Ensures only one logger instance across the app
- **Multiple Log Levels**: Debug, Info, Warning, Error, Fatal, Verbose
- **Specialized Logging Methods**: For API calls, file operations, permissions, etc.
- **Emoji Support**: Visual indicators for different types of logs
- **Structured Logging**: Support for parameters and detailed information
- **Method Entry/Exit Tracking**: Automatic method call logging

### Usage Examples

#### Basic Logging
```dart
final _logger = LoggerService.instance;

_logger.debug('Debug message');
_logger.info('Info message');
_logger.warning('Warning message');
_logger.error('Error message', exception);
_logger.fatal('Fatal error', exception);
_logger.verbose('Verbose message');
```

#### Method Entry/Exit Logging
```dart
void someMethod(String param) {
  _logger.methodEntry('someMethod', {'param': param});
  
  try {
    // Your code here
    _logger.methodExit('someMethod', 'Success');
  } catch (e) {
    _logger.methodExit('someMethod', 'Error occurred');
    rethrow;
  }
}
```

#### API Request/Response Logging
```dart
_logger.apiRequest('POST', 'https://api.example.com/data', headers, body);
_logger.apiResponse('POST', 'https://api.example.com/data', 200, responseBody);
```

#### File Operations
```dart
_logger.fileOperation('created', '/path/to/file.txt', {'size': 1024});
_logger.fileOperation('deleted', '/path/to/file.txt');
```

#### Permission Checks
```dart
_logger.permissionCheck('Camera', true);  // Granted
_logger.permissionCheck('Location', false); // Denied
```

#### Location Updates
```dart
_logger.locationUpdate(12.9716, 77.5946, 'Bangalore, India');
```

#### Image Processing
```dart
_logger.imageProcessing('compressed', '/path/to/image.jpg', {
  'originalSize': 2048576,
  'compressedSize': 512000,
  'compressionRatio': '75%'
});
```

## Updated Services

### 1. CameraService (`camera_service.dart`)
- Added logging for image picking operations
- Tracks file operations and user cancellations
- Logs errors during camera/gallery access

### 2. LocationService (`location_service.dart`)
- Comprehensive permission logging
- Location service status tracking
- GPS coordinate logging
- Settings navigation logging

### 3. DepartmentService (`department_service.dart`)
- API request/response logging
- Department data loading tracking
- Error handling with detailed logging

### 4. ComplaintService (`complaint_service.dart`)
- Complete complaint submission flow logging
- Image compression tracking
- API connectivity testing
- File cleanup operations
- Complaint retrieval logging

## Log Levels

- **Debug**: Detailed information for debugging
- **Info**: General information about app flow
- **Warning**: Potential issues that don't stop execution
- **Error**: Errors that affect functionality
- **Fatal**: Critical errors that may crash the app
- **Verbose**: Very detailed information (use sparingly)

## Configuration

The logger is configured with:
- **Method Count**: 2 (shows 2 stack trace levels)
- **Error Method Count**: 8 (shows 8 stack trace levels for errors)
- **Line Length**: 120 characters
- **Colors**: Enabled for better readability
- **Emojis**: Enabled for visual indicators
- **Time**: Enabled to show timestamps
- **Log Level**: Debug (shows all levels)

## Best Practices

1. **Use Appropriate Log Levels**: Don't use debug for production, use info/warning/error
2. **Include Context**: Always provide relevant parameters and context
3. **Method Entry/Exit**: Use for complex methods to track execution flow
4. **Error Logging**: Always include the exception object for stack traces
5. **Sensitive Data**: Never log passwords, tokens, or personal information
6. **Performance**: Avoid expensive operations in logging calls

## Example Output

```
🚀 Entering submitComplaint with params: {username: user123, description: Street light broken, departmentId: 1, attachmentsCount: 2}
🌐 API Request: POST http://192.168.1.34:8080/complaints/register-with-images
🖼️ Image processing: /path/to/image1.jpg
🖼️ Image compressed successfully: /path/to/compressed_image1.jpg
✅ API Response: POST http://192.168.1.34:8080/complaints/register-with-images - Status: 200
✅ Exiting submitComplaint with result: Success
``` 