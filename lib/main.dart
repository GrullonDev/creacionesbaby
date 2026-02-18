import 'package:creacionesbaby/pages/admin/admin_login_page.dart';
import 'package:creacionesbaby/pages/coming_soon_page.dart';
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
      home: kIsWeb ? const ComingSoonPage() : const AdminLoginPage(),
    );
  }
}
