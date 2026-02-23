import 'package:creacionesbaby/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  String _selectedSection = 'shipping';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Centro de Ayuda'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 20,
                vertical: 60,
              ),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 250, child: _buildSidebar()),
                        const SizedBox(width: 60),
                        Expanded(child: _buildContent()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildSidebar(),
                        const SizedBox(height: 40),
                        _buildContent(),
                      ],
                    ),
            ),
            _buildContactSection(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSoft.withValues(alpha: 0.5),
      ),
      child: Column(
        children: [
          Text(
            '¿Cómo podemos ayudarte hoy?',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          const Text(
            'Estamos aquí para que tu experiencia como madre sea lo más sencilla posible. Encuentra respuestas a nuestras dudas más comunes a continuación.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.primaryMedium, fontSize: 16),
          ),
          const SizedBox(height: 40),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Busca por envíos, tallas, devoluciones...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        _sidebarItem(
          id: 'shipping',
          icon: Icons.local_shipping_outlined,
          label: 'Envíos',
        ),
        _sidebarItem(
          id: 'returns',
          icon: Icons.keyboard_return_outlined,
          label: 'Devoluciones y Reembolsos',
        ),
        _sidebarItem(
          id: 'sizes',
          icon: Icons.straighten_outlined,
          label: 'Guía de Tallas',
        ),
        _sidebarItem(
          id: 'payments',
          icon: Icons.payment_outlined,
          label: 'Métodos de Pago',
        ),
      ],
    );
  }

  Widget _sidebarItem({
    required String id,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedSection == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedSection = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.primaryMedium,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.primaryDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedSection) {
      case 'shipping':
        return _buildShippingContent();
      case 'returns':
        return _buildReturnsContent();
      case 'sizes':
        return _buildSizeGuide();
      default:
        return _buildShippingContent();
    }
  }

  Widget _buildShippingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.local_shipping_outlined, 'Información de Envío'),
        const SizedBox(height: 32),
        _faqItem(
          '¿Cuáles son los tiempos de entrega?',
          'El envío estándar suele tardar de 3 a 5 días hábiles dentro del país. El envío express está disponible para entrega al día siguiente.',
        ),
        _faqItem(
          '¿Cuánto cuesta el envío?',
          'El envío es gratuito en todos los pedidos superiores a Q500. Para pedidos inferiores, se aplica una tarifa fija de Q25 para envío estándar.',
        ),
        _faqItem(
          '¿Ofrecen envíos internacionales?',
          'Sí, actualmente enviamos a más de 20 países. Los tiempos de envío internacional varían de 7 a 14 días hábiles.',
        ),
      ],
    );
  }

  Widget _buildReturnsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          Icons.keyboard_return_outlined,
          'Devoluciones y Reembolsos',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.pastelGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryGreen),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Ofrecemos una política de devolución de 30 días sin preocupaciones. Si no estás satisfecha con tu compra, lo solucionaremos.',
                  style: TextStyle(color: AppTheme.primaryDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _faqItem(
          '¿Cómo inicio una devolución?',
          'Para iniciar una devolución, inicia sesión en tu cuenta, ve a "Mis Pedidos" y selecciona "Devolver artículo" junto al pedido que deseas enviar.',
        ),
        _faqItem(
          '¿Qué artículos se pueden devolver?',
          'Los artículos deben estar en su estado original, sin usar y con las etiquetas puestas. Por razones de higiene, algunos artículos como la ropa interior no son devuelvibles.',
        ),
      ],
    );
  }

  Widget _buildSizeGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.straighten_outlined, 'Guía de Tallas'),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Table(
            children: [
              _tableHeader(['Edad', 'Peso (kg)', 'Altura (cm)']),
              _tableRow(['Recién Nacido', '2.5 - 4.0 kg', 'Hasta 50 cm']),
              _tableRow(['0-3 Meses', '4.0 - 6.0 kg', '50 - 60 cm']),
              _tableRow(['3-6 Meses', '6.0 - 8.0 kg', '60- 70 cm']),
              _tableRow(['6-12 Meses', '8.0 - 10.5 kg', '70 - 80 cm']),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '* Las medidas son aproximadas. Si tu bebé está entre dos tallas, recomendamos elegir la más grande para mayor comodidad.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  TableRow _tableHeader(List<String> cells) {
    return TableRow(
      decoration: BoxDecoration(color: AppTheme.backgroundSoft),
      children: cells
          .map(
            (c) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                c,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _tableRow(List<String> cells) {
    return TableRow(
      children: cells
          .map(
            (c) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(c, style: const TextStyle(fontSize: 13)),
            ),
          )
          .toList(),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 28),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              answer,
              style: const TextStyle(
                color: AppTheme.primaryMedium,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: AppTheme.pastelGreen.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        children: [
          const Icon(Icons.help_outline, size: 80, color: Colors.black12),
          const SizedBox(height: 32),
          const Text(
            '¿Aún tienes preguntas?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nuestras expertas están listas para ayudarte a elegir lo mejor para tu pequeño. ¡Estamos a un mensaje de distancia!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.primaryMedium, fontSize: 16),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () =>
                    launchUrl(Uri.parse('https://wa.me/50242909548')),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat en WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              OutlinedButton.icon(
                onPressed: () =>
                    launchUrl(Uri.parse('mailto:hola@creacionesbaby.com')),
                icon: const Icon(Icons.email_outlined),
                label: const Text('Soporte por Email'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
