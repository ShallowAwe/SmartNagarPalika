import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AppConfig {
  // Logger instance
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // API endpoints
  static String get baseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');

  static String get authBaseUrl =>
      dotenv.get('API_BASE_URL_AUTH', fallback: '$baseUrl/auth');

  static String get citizenBaseUrl =>
      dotenv.get('API_BASE_URL_CITIZEN', fallback: '$baseUrl/citizen');

  static String get employeeBaseUrl =>
      dotenv.get('API_BASE_URL_EMPLOYEE', fallback: '$baseUrl/employee');

  // App settings
  static int get timeoutSeconds =>
      int.tryParse(dotenv.get('API_TIMEOUT_SECONDS', fallback: '30')) ?? 30;

  static bool get isDebugMode =>
      dotenv.get('DEBUG_MODE', fallback: 'false').toLowerCase() == 'true';

  // Validate configuration
  static void validate() {
    _logger.i('Validating App Configuration...');

    if (baseUrl.isEmpty) throw Exception('API_BASE_URL is required');
    if (authBaseUrl.isEmpty) throw Exception('API_BASE_URL_AUTH is required');
    if (citizenBaseUrl.isEmpty) throw Exception('API_BASE_URL_CITIZEN is required');
    if (employeeBaseUrl.isEmpty) throw Exception('API_BASE_URL_EMPLOYEE is required');

    if (isDebugMode) {
      _logger.i('Base URL: $baseUrl');
      _logger.i('Auth API: $authBaseUrl');
      _logger.i('Citizen API: $citizenBaseUrl');
      _logger.i('Employee API: $employeeBaseUrl');
      _logger.d('Timeout: ${timeoutSeconds}s');
      _logger.d('Debug Mode: ON');
    }

    _logger.i('Configuration validation completed');
  }

  // Logger access
  static Logger get logger => _logger;

  // Log API calls
  static void logApiCall(String method, String url, {int? statusCode}) {
    if (!isDebugMode) return;

    if (statusCode != null) {
      if (statusCode >= 200 && statusCode < 300) {
        _logger.i('$method $url - Status: $statusCode');
      } else {
        _logger.e('$method $url - Status: $statusCode');
      }
    } else {
      _logger.d('$method $url');
    }
  }
}
