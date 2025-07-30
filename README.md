# Smart Nagarpalika

A comprehensive Flutter application for municipal services and citizen engagement. This application provides a modern interface for citizens to interact with their local municipal authority, submit complaints, access services, and discover nearby facilities.

## 🚀 Features

### Core Functionality
- **Complaint Management**: Submit and track complaints with image attachments
- **Service Discovery**: Access various municipal services through an intuitive grid interface
- **Location Services**: Find nearby facilities like hospitals, schools, police stations, etc.
- **News & Updates**: Stay informed with the latest municipal news and announcements
- **User Authentication**: Secure access with basic authentication

### Recent Enhancements (v2.0.0)
- **Advanced Image Compression**: Automatic image optimization for faster uploads
- **Enhanced Error Handling**: Comprehensive error recovery and user feedback
- **Connectivity Testing**: Pre-upload connectivity verification
- **Performance Optimization**: Improved upload speeds and resource management
- **Debug Logging**: Detailed logging for troubleshooting and monitoring

## 📱 Screens

### 1. Home Screen
- Service grid layouts (Quick & Popular Services)
- News section with horizontal scrolling
- Bottom navigation integration
- Top container with branding

### 2. Complaint Registration Screen
- Multi-step form with validation
- Camera integration for photo capture
- GPS location services
- Category selection
- **NEW**: Advanced image compression (70% quality, 1024px max)
- **NEW**: Automatic file cleanup after upload

### 3. Complaints Screen
- Complaint list with status indicators
- Image attachment handling with caching
- Status-based actions (Edit, Cancel, Rate)
- Detailed complaint popup

### 4. Near Me Screen
- Google Maps integration
- Location-based facility search
- Multi-category filtering
- External navigation integration

### 5. Redirecting Screen
- Embedded web browser for external services
- Cross-platform web view support
- Navigation integration

## 🛠 Technical Stack

### Frontend
- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **UI**: Material Design with custom components

### Key Dependencies
- `geolocator: ^14.0.2` - Location services
- `google_maps_flutter: ^2.12.3` - Map integration
- `image_picker: ^1.1.2` - Image capture
- `permission_handler: ^12.0.1` - Permission management
- `flutter_image_compress: ^2.4.0` - **NEW**: Image compression
- `cached_network_image: ^3.4.1` - **NEW**: Image caching
- `flutter_cache_manager: ^3.3.1` - **NEW**: Cache management
- `webview_flutter: ^4.13.0` - Web view support
- `adaptive_dialog: ^2.4.2` - Dialog management
- `url_launcher: ^6.3.1` - URL handling

### Backend Integration
- **API Base URL**: `http://192.168.1.34:8080`
- **Authentication**: Basic Auth
- **Image Upload**: Multipart form data with compression
- **Complaint Management**: RESTful API endpoints

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android development)
- iOS SDK (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart_nagarpalika
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure platform-specific settings**
   - Android: Update `android/app/build.gradle.kts` if needed
   - iOS: Update `ios/Runner/Info.plist` for permissions

4. **Run the application**
   ```bash
   flutter run
   ```

### Configuration

#### API Configuration
Update the base URL in `lib/Services/complaintService.dart`:
```dart
final String _baseUrl = 'http://your-api-server:port/complaints/register-with-images';
```

#### Authentication
Update credentials in `lib/Services/complaintService.dart`:
```dart
final String _username = 'your-username';
final String _password = 'your-password';
```

#### Google Maps API Key
For the Near Me screen functionality, add your Google Maps API key to:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/AppDelegate.swift`

## 📁 Project Structure

```
smart_nagarpalika/
├── lib/
│   ├── Data/                 # Dummy data and mock services
│   ├── Model/               # Data models
│   ├── Screens/             # UI screens with documentation
│   ├── Services/            # API services and utilities
│   ├── utils/               # Utility functions and widgets
│   ├── widgets/             # Reusable UI components
│   └── main.dart           # Application entry point
├── assets/                  # Images and static resources
├── android/                 # Android-specific configuration
├── ios/                     # iOS-specific configuration
└── test/                    # Unit and widget tests
```

## 🔧 Recent Improvements

### Image Processing System
- **Automatic Compression**: Images are compressed to 70% quality with max 1024px dimensions
- **Compression Monitoring**: Real-time compression ratio tracking
- **Fallback Mechanism**: Original files used if compression fails
- **Automatic Cleanup**: Temporary files removed after upload

### Error Handling & Debugging
- **Connectivity Testing**: Pre-upload network verification
- **Extended Timeouts**: 60-second timeout for large uploads
- **Detailed Logging**: Comprehensive console output for debugging
- **Graceful Recovery**: User-friendly error messages and recovery options

### Performance Optimizations
- **Memory Management**: Efficient file processing and cleanup
- **Request Monitoring**: Size and field validation
- **Resource Cleanup**: Automatic temporary file removal
- **Caching**: Image caching for improved performance

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## 📚 Documentation

Comprehensive documentation is available for each screen:
- [Home Screen Documentation](lib/Screens/HomeScreen.md)
- [Complaint Registration Documentation](lib/Screens/ComplaintRegistrationScreen.md)
- [Complaints Screen Documentation](lib/Screens/ComplaintsScreen.md)
- [Near Me Screen Documentation](lib/Screens/NearMeScreen.md)
- [Redirecting Screen Documentation](lib/Screens/RedirectingScreen.md)

## 🐛 Troubleshooting

### Common Issues

1. **Image Upload Failures**
   - Check network connectivity
   - Verify file permissions
   - Monitor compression ratios in console

2. **Location Services**
   - Ensure GPS permissions are granted
   - Check device location settings
   - Verify Google Maps API key configuration

3. **Authentication Errors**
   - Verify API credentials in service files
   - Check network connectivity to backend
   - Review authentication headers

4. **Performance Issues**
   - Monitor compression ratios
   - Check available storage space
   - Verify network stability

### Debug Mode
Enable detailed logging by checking console output for:
- Compression ratios
- Connectivity test results
- Request/response details
- File processing status

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Include proper error handling
- Add comprehensive documentation
- Test thoroughly before submission

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

**Smart Nagarpalika Development Team**

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation files in `lib/Screens/`

---

**Version**: 2.0.0  
**Last Updated**: December 2024  
**Flutter Version**: 3.8.1+
