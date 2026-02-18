import 'package:creacionesbaby/features/auth/presentation/pages/admin_login_page.dart';
import 'package:creacionesbaby/features/store/home/presentation/pages/store_home_page.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creaciones Baby',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      // Route based on platform
      home: kIsWeb ? const StoreHomePage() : const AdminLoginPage(),
    );
  }
}
