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
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF80CBC4),
          primary: const Color(0xFF26A69A),
          secondary: const Color(0xFFF48FB1),
          tertiary: const Color(0xFF90CAF9),
          surface: const Color(0xFFFAFAFA),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFA),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF4A4A4A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF4A4A4A)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF26A69A).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF26A69A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF26A69A).withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF26A69A).withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF26A69A), width: 2),
          ),
          prefixIconColor: const Color(0xFF26A69A),
          labelStyle: const TextStyle(color: Color(0xFF757575)),
        ),
      ),
      // Route based on platform
      home: kIsWeb ? const StoreHomePage() : const AdminLoginPage(),
    );
  }
}
