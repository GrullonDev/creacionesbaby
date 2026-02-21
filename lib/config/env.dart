enum Environment { dev, prod }

class AppConfig {
  static Environment environment = Environment.dev;

  static String get supabaseUrl {
    switch (environment) {
      case Environment.prod:
        return 'https://chjrzhzhbrzmqatavtnf.supabase.co'; // Production URL
      case Environment.dev:
        // Potentially same URL if using Branching, or different project
        // If Supabase Branching is enabled, we might use the same URL but different headers
        // OR different URLs if they are completely separate projects.
        // Assuming Branching with same project URL but maybe different API keys or just relying on database branches:
        return 'https://chjrzhzhbrzmqatavtnf.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    switch (environment) {
      case Environment.prod:
        return 'sb_publishable_crTFjO_2AAM2l7vdON5d5w_LPbf4vve';
      case Environment.dev:
        return 'sb_publishable_crTFjO_2AAM2l7vdON5d5w_LPbf4vve';
    }
  }
}
