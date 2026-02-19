import 'dart:io';

import 'package:backend/config/env.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';

void main(List<String> args) async {
  // 1. Initialize Configuration (Load .env)
  await Env.load();

  // 2. Initialize Supabase Client (if keys are present)
  final supabaseUrl = Env.supabaseUrl;
  final supabaseKey = Env.supabaseServiceKey;

  SupabaseClient? supabase;
  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    supabase = SupabaseClient(supabaseUrl, supabaseKey);
    print('✅ Supabase initialized for: $supabaseUrl');
  } else {
    print('⚠️ Supabase credentials missing in .env');
  }

  // 3. Define Routes
  final router = Router();

  // Basic health check
  router.get('/', (Request request) {
    return Response.ok(
        'Creaciones Baby Backend is Running! 🚀\nMode: ${Env.isProduction ? 'PRODUCTION' : 'DEVELOPMENT'}');
  });

  // Example API endpoint: List basic info
  router.get('/api/info', (Request request) {
    return Response.ok('{"version": "1.0.0", "service": "creaciones-baby-api"}',
        headers: {'content-type': 'application/json'});
  });

  // Example Supabase Query (e.g., list users or products via backend)
  // This is where n8n or other services might hit to trigger logic
  router.get('/api/test-db', (Request request) async {
    if (supabase == null) {
      return Response.internalServerError(body: 'Database not configured');
    }
    try {
      // Example: Fetch a few rows from a table named 'products' if it exists
      // final data = await supabase.from('products').select().limit(5);
      // return Response.ok(data.toString());
      return Response.ok('Database connected (Table query commented out)');
    } catch (e) {
      return Response.internalServerError(body: 'Database error: $e');
    }
  });

  // 4. Create Handler Pipeline
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  // 5. Start Server
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
