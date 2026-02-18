class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imagePath;
  final bool
  isLocal; // To identify if the image is only available locally on the device

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imagePath,
    this.isLocal = true,
  });
}
