import 'package:creacionesbaby/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedSubject = 'Consulta General';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Contacto'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroBanner(context),
            const SizedBox(height: 80),
            _buildSupportCategories(context, isDesktop),
            const SizedBox(height: 100),
            _buildMessageAndContactInfo(context, isDesktop),
            const SizedBox(height: 100),
            _buildLocationSection(context, isDesktop),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de Contacto',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        _contactDetail(
          Icons.access_time_filled_rounded,
          'Horarios de Atención',
          'Lunes a Viernes: 09:00 - 18:00\nSábados: 09:00 - 13:00',
        ),
        _contactDetail(
          Icons.phone_android_rounded,
          'WhatsApp & Teléfono',
          '+502 4290 9548',
          actionText: 'Chatear ahora',
          onAction: () => launchUrl(Uri.parse('https://wa.me/50242909548')),
        ),
        _contactDetail(
          Icons.alternate_email_rounded,
          'Correo Electrónico',
          'hola@creacionesbaby.com\nsoporte@creacionesbaby.com',
        ),
        _contactDetail(
          Icons.location_on_rounded,
          'Ubicación',
          'Km 15.5 Carretera a El Salvador\nCondominio El Prado, Guatemala',
        ),
        const SizedBox(height: 40),
        const Text(
          'SÍGUENOS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryMedium,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _socialIcon(Icons.camera_alt_outlined),
            const SizedBox(width: 12),
            _socialIcon(Icons.facebook_outlined),
            const SizedBox(width: 12),
            _socialIcon(Icons.chat_bubble_outline_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: AppTheme.backgroundSoft.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.1),
            AppTheme.primaryGreen.withValues(alpha: 0.3),
            AppTheme.primaryGreen.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Estamos aquí para ayudarte',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Cuidamos cada detalle para los más pequeños. Si tienes dudas sobre tallas, pedidos o envíos, nuestro equipo está listo para asistirte.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.primaryMedium),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                ),
                child: const Text('Ver Preguntas Frecuentes'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                ),
                child: const Text('Centro de Ayuda'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Nuestra Ubicación',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Container(
          height: 400,
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80\u0026w=1200',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppTheme.primaryGreen,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Creaciones Baby Central',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Haz clic para abrir en Google Maps',
                    style: TextStyle(
                      color: AppTheme.primaryMedium.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageAndContactInfo(BuildContext context, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildSupportForm(context)),
                const SizedBox(width: 60),
                Expanded(flex: 2, child: _buildContactInfo(context)),
              ],
            )
          : Column(
              children: [
                _buildSupportForm(context),
                const SizedBox(height: 60),
                _buildContactInfo(context),
              ],
            ),
    );
  }

  Widget _buildSubjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asunto',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundSoft.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSubject,
              isExpanded: true,
              items:
                  [
                    'Consulta General',
                    'Pedido Pendiente',
                    'Tallas y Medidas',
                    'Devoluciones',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCategories(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        Text(
          '¿Cómo podemos apoyarte hoy?',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 48),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return Row(
                  children: [
                    Expanded(
                      child: _supportCard(
                        context,
                        Icons.straighten_rounded,
                        'Asesoría de Tallas',
                        'Te ayudamos a elegir la mejor opción según la etapa de crecimiento de tu bebé.',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _supportCard(
                        context,
                        Icons.local_shipping_outlined,
                        'Estado de Pedido',
                        'Rastrea tu compra en tiempo real y conoce la fecha estimada de entrega.',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _supportCard(
                        context,
                        Icons.shopping_bag_outlined,
                        'Dudas sobre Productos',
                        'Consultas técnicas sobre materiales, cuidados y disponibilidad de stock.',
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _supportCard(
                      context,
                      Icons.straighten_rounded,
                      'Asesoría de Tallas',
                      'Te ayudamos a elegir la mejor opción según la etapa de crecimiento de tu bebé.',
                    ),
                    const SizedBox(height: 24),
                    _supportCard(
                      context,
                      Icons.local_shipping_outlined,
                      'Estado de Pedido',
                      'Rastrea tu compra en tiempo real y conoce la fecha estimada de entrega.',
                    ),
                    const SizedBox(height: 24),
                    _supportCard(
                      context,
                      Icons.shopping_bag_outlined,
                      'Dudas sobre Productos',
                      'Consultas técnicas sobre materiales, cuidados y disponibilidad de stock.',
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupportForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                Text(
                  'Envíanos un mensaje',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    label: 'Nombre Completo',
                    hint: 'Ej. Ana García',
                    controller: _nameController,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildFormField(
                    label: 'Correo Electrónico',
                    hint: 'ana@ejemplo.com',
                    controller: _emailController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSubjectDropdown(),
            const SizedBox(height: 24),
            _buildFormField(
              label: 'Mensaje',
              hint: '¿En qué podemos ayudarte?',
              maxLines: 5,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enviar Mensaje'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactDetail(
    IconData icon,
    String title,
    String detail, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyle(
                    color: AppTheme.primaryMedium.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                if (actionText != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onAction,
                    child: Text(
                      actionText,
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppTheme.primaryMedium, size: 20),
    );
  }

  Widget _supportCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.primaryMedium.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
