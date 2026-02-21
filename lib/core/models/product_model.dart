import 'dart:convert';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imagePath; // Primary image (backward-compat)
  final List<String> imageUrls; // All images (1-5)
  final String? category;
  final bool isActive;
  final bool isLocal;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imagePath,
    List<String>? imageUrls,
    this.category,
    this.isActive = true,
    this.isLocal = true,
  }) : imageUrls = imageUrls ?? (imagePath != null ? [imagePath] : []);

  /// Parse image_url field which can be:
  /// - A JSON array string: '["url1","url2"]'
  /// - A single URL string: 'https://...'
  /// - null
  static List<String> _parseImageUrl(dynamic value) {
    if (value == null) return [];
    final str = value.toString().trim();
    if (str.isEmpty) return [];

    // Try parsing as JSON array
    if (str.startsWith('[')) {
      try {
        final List<dynamic> parsed = jsonDecode(str);
        return parsed
            .map((e) => e.toString())
            .where((url) => url.isNotEmpty)
            .toList();
      } catch (_) {
        // Not valid JSON, treat as single URL
      }
    }

    // Single URL string
    return [str];
  }

  /// Create from Supabase JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final allImages = _parseImageUrl(json['image_url']);

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      imagePath: allImages.isNotEmpty ? allImages.first : null,
      imageUrls: allImages,
      category: json['category'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isLocal: false,
    );
  }

  /// Convert to JSON for Supabase insert/update.
  /// Stores all image URLs as a JSON array string in `image_url`.
  Map<String, dynamic> toJson() {
    String? imageUrlValue;
    if (imageUrls.isNotEmpty) {
      if (imageUrls.length == 1) {
        imageUrlValue = imageUrls.first; // Single URL as plain string
      } else {
        imageUrlValue = jsonEncode(imageUrls); // Multiple as JSON array
      }
    } else {
      imageUrlValue = imagePath;
    }

    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrlValue,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imagePath,
    List<String>? imageUrls,
    String? category,
    bool? isActive,
    bool? isLocal,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}
