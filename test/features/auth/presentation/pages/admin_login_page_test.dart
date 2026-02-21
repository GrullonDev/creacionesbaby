import 'package:creacionesbaby/core/providers/auth_provider.dart';
import 'package:creacionesbaby/features/auth/presentation/pages/admin_login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  bool _isLoading = false;
  String? _error;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  User? get currentUser => null;

  @override
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network

    if (email == 'admin@test.com' && password == 'password123') {
      _isLoading = false;
      _error = null;
    } else {
      _isLoading = false;
      _error = 'Correo o contraseña incorrectos.';
    }
    notifyListeners();
  }

  @override
  Future<void> signUp(String email, String password) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  group('AdminLoginPage Widget Tests', () {
    late FakeAuthProvider authProvider;

    setUp(() {
      authProvider = FakeAuthProvider();
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(home: AdminLoginPage()),
      );
    }

    testWidgets('Renders Login Form Correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Allow animations to settle
      await tester.pumpAndSettle();

      // Verify Texts
      expect(find.text('Creaciones Baby'), findsOneWidget);
      expect(find.text('Panel de Administración'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);

      // Verify TextFields
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Verify Button
      expect(find.text('INGRESAR'), findsOneWidget);
    });

    testWidgets('Shows validation errors on empty submit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the login button without entering data
      await tester.tap(find.text('INGRESAR'));
      await tester.pump(); // Trigger frame for validation errors

      expect(find.text('Ingresa tu correo'), findsOneWidget);
      expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    });
  });
}
