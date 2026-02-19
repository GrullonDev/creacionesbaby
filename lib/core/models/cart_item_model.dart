import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:uuid/uuid.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final String size; // e.g., 'S', 'M', 'L' or other variations
  final DateTime addedAt;

  CartItemModel({
    String? id,
    required this.product,
    this.quantity = 1,
    this.size = 'Única',
    DateTime? addedAt,
  }) : id = id ?? const Uuid().v4(),
       addedAt = addedAt ?? DateTime.now();

  double get totalPrice => (product.price * quantity);

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    String? size,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
