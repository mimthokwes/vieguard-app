import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String get origin =>
      dotenv.maybeGet('API_ORIGIN') ?? 'http://localhost:5000';

  static String get baseUrl => '$origin/api/v0/mobile';
}
