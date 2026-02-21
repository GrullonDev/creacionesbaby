import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('ProductModel Serialization Tests', () {
    test('fromJson handles null image_url gracefully', () {
      final json = {
        'id': '1',
        'name': 'Test Product',
        'description': 'Description',
        'price': 10.0,
        'stock': 5,
        'image_url': null,
      };

      final product = ProductModel.fromJson(json);

      expect(product.imagePath, isNull);
      expect(product.imageUrls, isEmpty);
    });

    test('fromJson handles single string image_url', () {
      final json = {
        'id': '1',
        'name': 'Test Product',
        'description': 'Description',
        'price': 10.0,
        'stock': 5,
        'image_url': 'https://example.com/image.jpg',
      };

      final product = ProductModel.fromJson(json);

      expect(product.imagePath, 'https://example.com/image.jpg');
      expect(product.imageUrls, ['https://example.com/image.jpg']);
    });

    test('fromJson handles JSON array string image_url', () {
      final urls = [
        'https://example.com/img1.jpg',
        'https://example.com/img2.jpg',
      ];
      final json = {
        'id': '1',
        'name': 'Test Product',
        'description': 'Description',
        'price': 10.0,
        'stock': 5,
        'image_url': jsonEncode(urls),
      };

      final product = ProductModel.fromJson(json);

      expect(product.imagePath, 'https://example.com/img1.jpg');
      expect(product.imageUrls, urls);
    });

    test('toJson encodes single image as plain string', () {
      final product = ProductModel(
        id: '1',
        name: 'Test',
        description: 'Desc',
        price: 10.0,
        stock: 5,
        imageUrls: ['https://example.com/img.jpg'],
      );

      final json = product.toJson();

      expect(json['image_url'], 'https://example.com/img.jpg');
    });

    test('toJson encodes multiple images as JSON array string', () {
      final product = ProductModel(
        id: '1',
        name: 'Test',
        description: 'Desc',
        price: 10.0,
        stock: 5,
        imageUrls: [
          'https://example.com/img1.jpg',
          'https://example.com/img2.jpg',
        ],
      );

      final json = product.toJson();

      expect(json['image_url'], isA<String>());
      final decoded = jsonDecode(json['image_url'] as String) as List<dynamic>;
      expect(decoded.length, 2);
      expect(decoded[0], 'https://example.com/img1.jpg');
    });
  });
}
