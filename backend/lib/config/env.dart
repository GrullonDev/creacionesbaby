import 'package:dotenv/dotenv.dart';

class Env {
  static final _dotenv = DotEnv(includePlatformEnvironment: true)..load();

  static String get supabaseUrl => _dotenv['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => _dotenv['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseServiceKey =>
      _dotenv['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  static bool get isProduction => _dotenv['ENVIRONMENT'] == 'production';

  static Future<void> load() async {
    // If needed, load specific multiple .env files
    // Usually, we just load '.env'
    print('📦 Environment loaded: ${_dotenv['ENVIRONMENT'] ?? 'development'}');
  }
}
