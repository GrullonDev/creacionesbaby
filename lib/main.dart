import 'package:creacionesbaby/config/env.dart';
import 'package:creacionesbaby/core/providers/app_config_provider.dart';
import 'package:creacionesbaby/core/providers/auth_provider.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/core/providers/order_provider.dart';
import 'package:creacionesbaby/firebase_options.dart';
import 'package:creacionesbaby/utils/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool initSuccess = false;
  try {
    debugPrint('🚀 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initializamos Supabase primero para asegurar que los providers tengan acceso
    debugPrint('🚀 Initializing Supabase...');
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    debugPrint('✅ Supabase initialized');
    initSuccess = true;

    if (kIsWeb) {
      debugPrint('ℹ️ Stripe init deferred to payment screen on Web');
    } else {
      // En móvil, si lo necesitas al inicio, podrías intentar inicializarlo
      // pero el usuario indicó que lo manejaremos después.
      debugPrint('ℹ️ Initializing Stripe deferred');
    }
  } catch (e, stack) {
    debugPrint('❌ Initialization error: $e');
    debugPrint('Stack trace: $stack');
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
      ],
      child: const MyApp(),
    ),
  );
}
