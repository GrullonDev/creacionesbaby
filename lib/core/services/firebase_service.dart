import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  static FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;

  // Track page views
  static Future<void> logScreenView(String screenName) async {
    await analytics.logScreenView(screenName: screenName);
    debugPrint('📊 Firebase Analytics: ScreenView -> $screenName');
  }

  // Track custom events (e.g. "add_to_cart", "purchase")
  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await analytics.logEvent(name: name, parameters: parameters);
    debugPrint('📊 Firebase Analytics: Event -> $name, Params: $parameters');
  }

  // Track errors manually
  static Future<void> logError(
    dynamic error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!kDebugMode) {
      await crashlytics.recordError(error, stack, reason: reason, fatal: fatal);
    }
    debugPrint('❌ Firebase Crashlytics: Error recorded -> $error');
  }

  // Set user properties
  static Future<void> setUserProperties({
    required String userId,
    String? email,
  }) async {
    await analytics.setUserId(id: userId);
    if (!kDebugMode) {
      await crashlytics.setUserIdentifier(userId);
    }
    if (email != null) {
      await analytics.setUserProperty(name: 'email', value: email);
    }
  }
}
