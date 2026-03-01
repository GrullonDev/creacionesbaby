class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'icon': icon};
  }
}
