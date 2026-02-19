import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/features/auth/presentation/pages/admin_login_page.dart';
import 'package:creacionesbaby/features/store/home/presentation/pages/store_home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creaciones Baby',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Route based on platform
      home: kIsWeb ? const StoreHomePage() : const AdminLoginPage(),
    );
  }
}
