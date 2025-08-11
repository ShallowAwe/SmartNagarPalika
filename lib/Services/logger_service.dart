import 'package:logger/logger.dart';

class LoggerService {
  static LoggerService? _instance;
  static LoggerService get instance => _instance ??= LoggerService._();

  late final Logger _logger;

  LoggerService._() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: Level.debug,
    );
  }

  // Debug level logging
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // Info level logging
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // Warning level logging
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // Error level logging
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(
      message,
      error: error?.toString(), // Safely convert error to String (handles null)
      stackTrace: stackTrace,
    );
  }

  // Fatal level logging
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Verbose level logging
  void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error: error, stackTrace: stackTrace);
  }

  // Method entry logging
  void methodEntry(String methodName, [Map<String, dynamic>? parameters]) {
    final params = parameters != null ? ' with params: $parameters' : '';
    _logger.d('🚀 Entering $methodName$params');
  }

  // Method exit logging
  void methodExit(String methodName, [dynamic result]) {
    final resultStr = result != null ? ' with result: $result' : '';
    _logger.d('✅ Exiting $methodName$resultStr');
  }

  // API request logging
  void apiRequest(
    String method,
    String url, [
    Map<String, dynamic>? headers,
    dynamic body,
  ]) {
    _logger.i('🌐 API Request: $method $url');
    if (headers != null) {
      _logger.d('Headers: $headers');
    }
    if (body != null) {
      _logger.d('Body: $body');
    }
  }

  // API response logging
  void apiResponse(
    String method,
    String url,
    int statusCode, [
    dynamic response,
  ]) {
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    _logger.i('$emoji API Response: $method $url - Status: $statusCode');
    if (response != null) {
      _logger.d('Response: $response');
    }
  }

  // File operation logging
  void fileOperation(String operation, String filePath, [dynamic result]) {
    _logger.i('📁 File $operation: $filePath');
    if (result != null) {
      _logger.d('Result: $result');
    }
  }

  // Permission logging
  void permissionCheck(String permission, bool granted) {
    final emoji = granted ? '✅' : '❌';
    _logger.i(
      '$emoji Permission $permission: ${granted ? 'GRANTED' : 'DENIED'}',
    );
  }

  // Location logging
  void locationUpdate(double latitude, double longitude, [String? address]) {
    _logger.i('📍 Location Update: $latitude, $longitude');
    if (address != null) {
      _logger.d('Address: $address');
    }
  }

  // Image processing logging
  void imageProcessing(
    String operation,
    String imagePath, [
    Map<String, dynamic>? details,
  ]) {
    _logger.i('🖼️ Image $operation: $imagePath');
    if (details != null) {
      _logger.d('Details: $details');
    }
  }
}
