import 'package:creacionesbaby/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  String _supabaseStatus = 'Cargando...';
  String _connectivityStatus = 'Verificando...';
  Map<String, String> _envInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() => _isLoading = true);

    // 1. Env Info
    _envInfo = {
      'Environment': AppConfig.environment.toString(),
      'Supabase URL': AppConfig.supabaseUrl,
      'Supabase Key': AppConfig.supabaseAnonKey.length > 10
          ? '${AppConfig.supabaseAnonKey.substring(0, 5)}...${AppConfig.supabaseAnonKey.substring(AppConfig.supabaseAnonKey.length - 5)}'
          : 'Inválida',
      'Platform': kIsWeb ? 'Web' : 'Mobile/Desktop',
      'Release Mode': kReleaseMode.toString(),
    };

    // 2. Connectivity & Supabase Check
    try {
      final supabase = Supabase.instance.client;
      final start = DateTime.now();
      await supabase.from('products').select().limit(1);
      final duration = DateTime.now().difference(start).inMilliseconds;

      _connectivityStatus = 'OK (Latencia: ${duration}ms)';
      _supabaseStatus = 'Conectado exitosamente';
    } catch (e) {
      _connectivityStatus = 'Fallo conexión backend';
      _supabaseStatus = 'Error: $e';
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico de Producción'),
        backgroundColor: Colors.orange[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection('Integridad de Red', [
                  _buildStatusItem(
                    'Conexión con Supabase',
                    _connectivityStatus,
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSection('Configuración del Entorno', [
                  _buildStatusItem('Supabase Auth/DB', _supabaseStatus),
                  ..._envInfo.entries.map(
                    (e) => _buildStatusItem(e.key, e.value),
                  ),
                ]),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Cerrar Diagnóstico'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: TextStyle(
              color: (value.contains('Error') || value.contains('Fallo'))
                  ? Colors.red
                  : Colors.black87,
              fontFamily: 'Courier',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
