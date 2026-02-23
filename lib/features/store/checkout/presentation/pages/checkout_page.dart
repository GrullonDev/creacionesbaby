import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/order_provider.dart';
import 'package:creacionesbaby/features/store/cart/presentation/pages/order_success_page.dart';
import 'package:creacionesbaby/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  String _selectedShippingMethod = 'standard';
  String _selectedPaymentMethod = 'bank';
  bool _sendNewsletters = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      final orderProvider = context.read<OrderProvider>();
      final cartProvider = context.read<CartProvider>();

      if (cartProvider.items.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tu carrito está vacío')));
        return;
      }

      final customerName = '${_nameCtrl.text} ${_lastNameCtrl.text}'.trim();

      final success = await orderProvider.createOrder(
        customerEmail: _emailCtrl.text,
        customerName: customerName,
        customerPhone: _phoneCtrl.text,
        shippingAddress:
            '${_addressCtrl.text}, ${_cityCtrl.text}, ${_zipCtrl.text}',
        totalAmount:
            cartProvider.totalAmount +
            (_selectedShippingMethod == 'standard' ? 25.0 : 50.0),
        cartItems: cartProvider.items,
      );

      if (success) {
        final items = List.from(cartProvider.items);
        final orderIdValue = orderProvider.lastCreatedOrderId;
        cartProvider.clearCart();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            SmoothPageRoute(
              page: OrderSuccessPage(
                orderId:
                    orderIdValue ??
                    'CB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                items: items,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${orderProvider.error}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: AppTheme.backgroundSoft,
      appBar: AppBar(
        title: const Text('FINALIZAR COMPRA'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProgressBar(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 20,
                vertical: 40,
              ),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildCheckoutSteps()),
                        const SizedBox(width: 40),
                        Expanded(flex: 2, child: _buildRightPanel(cart)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildRightPanel(cart),
                        const SizedBox(height: 32),
                        _buildCheckoutSteps(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepIcon(1, 'Carrito', true),
          _stepDivider(),
          _stepIcon(2, 'Envío', true),
          _stepDivider(),
          _stepIcon(3, 'Pago', true),
        ],
      ),
    );
  }

  Widget _stepIcon(int number, String label, bool active) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryGreen : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? AppTheme.primaryDark : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _stepDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Icon(Icons.chevron_right, size: 16, color: Colors.grey[300]),
    );
  }

  Widget _buildCheckoutSteps() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildStepCard(
            icon: Icons.contact_mail_outlined,
            title: 'Información de Contacto',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Correo electrónico'),
                _buildTextField(
                  controller: _emailCtrl,
                  hint: 'ejemplo@correo.com',
                  validator: (v) =>
                      v!.isEmpty || !v.contains('@') ? 'Email inválido' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _sendNewsletters,
                        onChanged: (v) => setState(() => _sendNewsletters = v!),
                        activeColor: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Enviarme noticias y ofertas exclusivas por correo',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildStepCard(
            icon: Icons.local_shipping_outlined,
            title: 'Dirección de Envío',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildFieldColumn('Nombre', _nameCtrl)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFieldColumn('Apellidos', _lastNameCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFieldColumn(
                  'Dirección',
                  _addressCtrl,
                  hint: 'Calle, número, piso...',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildFieldColumn('Ciudad', _cityCtrl)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFieldColumn('Código Postal', _zipCtrl),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildStepCard(
            icon: Icons.delivery_dining_outlined,
            title: 'Método de Envío',
            child: Column(
              children: [
                _buildSelectionRow(
                  id: 'standard',
                  title: 'Envío Estándar',
                  subtitle: 'Entrega en 3-5 días hábiles',
                  price: 'Q25.00',
                  groupValue: _selectedShippingMethod,
                  onChanged: (v) => setState(() => _selectedShippingMethod = v),
                ),
                const Divider(height: 1),
                _buildSelectionRow(
                  id: 'express',
                  title: 'Envío Express',
                  subtitle: 'Entrega en 24-48 horas',
                  price: 'Q50.00',
                  groupValue: _selectedShippingMethod,
                  onChanged: (v) => setState(() => _selectedShippingMethod = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildStepCard(
            icon: Icons.payment_outlined,
            title: 'Método de Pago',
            child: Column(
              children: [
                _buildPaymentOption(
                  id: 'bank',
                  title: 'Transferencia Bancaria',
                  icon: Icons.account_balance_outlined,
                  isExpanded: _selectedPaymentMethod == 'bank',
                  onTap: () => setState(() => _selectedPaymentMethod = 'bank'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Realiza tu pago directamente en nuestra cuenta bancaria. Tu pedido no se enviará hasta que el importe haya sido recibido.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryMedium,
                      ),
                    ),
                  ),
                ),
                /* _buildPaymentOption(
                  id: 'paypal',
                  title: 'PayPal',
                  icon: Icons.payment_outlined,
                  isExpanded: _selectedPaymentMethod == 'paypal',
                  onTap: () =>
                      setState(() => _selectedPaymentMethod = 'paypal'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Paga a través de PayPal; puedes pagar con tu tarjeta de crédito si no tienes una cuenta de PayPal.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryMedium,
                      ),
                    ),
                  ),
                ), */
                _buildPaymentOption(
                  id: 'cash',
                  title: 'Pago contra entrega',
                  icon: Icons.payments_outlined,
                  isExpanded: _selectedPaymentMethod == 'cash',
                  onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Paga en efectivo al momento de recibir tu pedido en la puerta de tu casa.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(24), child: child),
        ],
      ),
    );
  }

  Widget _buildFieldColumn(
    String label,
    TextEditingController ctrl, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        _buildTextField(controller: ctrl, hint: hint ?? ''),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppTheme.primaryMedium),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSelectionRow({
    required String id,
    required String title,
    required String subtitle,
    required String price,
    required String groupValue,
    required Function(String) onChanged,
  }) {
    final isSelected = id == groupValue;
    return InkWell(
      onTap: () => onChanged(id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
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
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    Widget? child,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryGreen
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(icon, color: Colors.grey[400], size: 20),
                ],
              ),
            ),
          ),
          if (isExpanded && child != null) ...[
            const Divider(height: 1),
            Padding(padding: const EdgeInsets.all(20), child: child),
          ],
        ],
      ),
    );
  }

  Widget _buildRightPanel(CartProvider cart) {
    const double shippingPrice = 25.0;
    const double taxes = 7.85; // Example
    final total = cart.totalAmount + shippingPrice + taxes;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen del Pedido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 32),
              ...cart.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          image: item.product.imagePath != null
                              ? DecorationImage(
                                  image: NetworkImage(item.product.imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                            ),
                            Text(
                              'Cantidad: ${item.quantity}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'Q${item.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 48),
              _summaryRow(
                'Subtotal',
                'Q${cart.totalAmount.toStringAsFixed(2)}',
              ),
              _summaryRow(
                'Gastos de Envío',
                'Q${shippingPrice.toStringAsFixed(2)}',
              ),
              _summaryRow(
                'Impuestos (IVA 21%)',
                'Q${taxes.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Q${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_outlined, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Finalizar Compra',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          side: const BorderSide(color: AppTheme.primaryGreen),
                        ),
                        child: const Text('Continuar Comprando'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _badgeInfo(Icons.verified_user_outlined, 'PAGO SEGURO SSL'),
                  _badgeInfo(Icons.history_outlined, 'GARANTÍA 30 DÍAS'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Código de descuento',
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(onPressed: () {}, child: const Text('Aplicar')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  static Widget _badgeInfo(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
