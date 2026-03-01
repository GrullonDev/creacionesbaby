class CouponModel {
  final String id;
  final String code;
  final double discount; // percentage if percentage is true, or absolute value
  final bool isPercentage;
  final bool isActive;
  final DateTime? validUntil;

  CouponModel({
    required this.id,
    required this.code,
    required this.discount,
    required this.isPercentage,
    this.isActive = true,
    this.validUntil,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'].toString(),
      code: json['code'],
      discount: (json['discount'] as num).toDouble(),
      isPercentage: json['is_percentage'] ?? true,
      isActive: json['is_active'] ?? true,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
    );
  }

  double calculateDiscount(double subtotal) {
    if (isPercentage) {
      return subtotal * (discount / 100);
    } else {
      return (subtotal >= discount) ? discount : subtotal;
    }
  }

  bool get isValid {
    if (!isActive) return false;
    if (validUntil != null && DateTime.now().isAfter(validUntil!)) return false;
    return true;
  }
}
