import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static const String defaultOrigin = 'https://api.vieguard.web.id';

  static String get origin {
    final raw = dotenv.maybeGet('API_ORIGIN')?.trim();
    if (raw != null && raw.isNotEmpty && !raw.contains('localhost') && !raw.contains('127.0.0.1')) {
      return raw;
    }
    return defaultOrigin;
  }

  static String get baseUrl => '$origin/api/v0/mobile';

  static String get appVersion {
    final v = dotenv.maybeGet('APP_VERSION')?.trim();
    if (v == null || v.isEmpty) return 'v1.2.5';
    return v.startsWith('v') || v.startsWith('V') ? v : 'v$v';
  }
}
