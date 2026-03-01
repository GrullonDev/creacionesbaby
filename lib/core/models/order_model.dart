class OrderItemModel {
  final String? id;
  final String orderId;
  final String productId;
  final String productName;
  final String size;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.size,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString(),
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      size: json['size'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'size': size,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}

class OrderModel {
  final String? id;
  final String customerEmail;
  final String customerName;
  final String customerPhone;
  final String shippingAddress;
  final double totalAmount;
  final double shippingAmount;
  final double taxAmount;
  final double discountAmount;
  final String status;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    this.id,
    required this.customerEmail,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.totalAmount,
    this.shippingAmount = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.status = 'pendiente',
    this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Para relacionar items si vienen en la consulta (ej. select('*, order_items(*)'))
    final itemsJson = json['order_items'] as List<dynamic>?;
    final items =
        itemsJson
            ?.map(
              (item) => OrderItemModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return OrderModel(
      id: json['id']?.toString(),
      customerEmail: json['customer_email'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      totalAmount: (json['total_amount'] as num).toDouble(),
      shippingAmount: (json['shipping_amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pendiente',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customer_email': customerEmail,
      'customer_name': customerName,
      'shipping_address': shippingAddress,
      'total_amount': totalAmount,
      'shipping_amount': shippingAmount,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'status': status,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerEmail,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    double? totalAmount,
    double? shippingAmount,
    double? taxAmount,
    double? discountAmount,
    String? status,
    DateTime? createdAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerEmail: customerEmail ?? this.customerEmail,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
