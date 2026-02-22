enum Environment { dev, prod }

class AppConfig {
  static Environment environment = Environment.dev;

  // Since both environments use the same database, we use a single URL and Key
  static const String _supabaseUrl = 'https://chjrzhzhbrzmqatavtnf.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_crTFjO_2AAM2l7vdON5d5w_LPbf4vve';

  static String get supabaseUrl => _supabaseUrl;
  static String get supabaseAnonKey => _supabaseAnonKey;
}
