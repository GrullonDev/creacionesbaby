import 'package:creacionesbaby/config/env.dart';
import 'package:creacionesbaby/core/providers/app_config_provider.dart';
import 'package:creacionesbaby/core/providers/auth_provider.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/core/providers/order_provider.dart';
import 'package:creacionesbaby/core/providers/contact_provider.dart';
import 'package:creacionesbaby/core/providers/wishlist_provider.dart';
import 'package:creacionesbaby/core/providers/category_provider.dart';
import 'package:creacionesbaby/core/services/logger_service.dart';
import 'package:creacionesbaby/firebase_options.dart';
import 'package:creacionesbaby/utils/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool initSuccess = false;
  // 🚀 Initializing Firebase
  try {
    debugPrint('🚀 Initializing Firebase...');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized');
    } else {
      debugPrint('ℹ️ Firebase already initialized');
    }

    // Initializamos Analytics
    FirebaseAnalytics.instance.logAppOpen();

    // Initializamos Crashlytics (solo fuera del modo debug)
    if (!kDebugMode) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      debugPrint('✅ Crashlytics initialized');
    }

    // Initializamos App Check
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaEnterpriseProvider(
        '6Lc-tuQqAAAAAIB_8v9f4v4v4v4v4v4v4v4v4v4v',
      ),
      appleProvider: AppleProvider.deviceCheck,
      androidProvider: AndroidProvider.playIntegrity,
    );
    debugPrint('✅ App Check initialized');
  } catch (e) {
    debugPrint('⚠️ Firebase services warning: $e');
    // No lanzamos error para permitir que Supabase intente iniciar
  }

  // 🚀 Initializing Supabase
  try {
    debugPrint('🚀 Initializing Supabase...');
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    debugPrint('✅ Supabase initialized');
    initSuccess = true;
  } catch (e, stack) {
    LoggerService.error('Supabase initialization error', e, stack);
  }

  if (kIsWeb) {
    debugPrint('ℹ️ Stripe init deferred to payment screen on Web');
  } else {
    // En móvil, si lo necesitas al inicio, podrías intentar inicializarlo
    // pero el usuario indicó que lo manejaremos después.
    debugPrint('ℹ️ Initializing Stripe deferred');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = AppConfigProvider();
            if (initSuccess) provider.loadConfig();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
