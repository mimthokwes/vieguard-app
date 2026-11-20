import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String get origin =>
      dotenv.maybeGet('API_ORIGIN') ?? 'https://api.vieguard.web.id';

  static String get baseUrl => '$origin/api/v0/mobile';

  static String get appVersion {
    final v = dotenv.maybeGet('APP_VERSION')?.trim();
    if (v == null || v.isEmpty) return 'v1.2.7';
    return v.startsWith('v') || v.startsWith('V') ? v : 'v$v';
  }
}
