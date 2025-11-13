class Product {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String barcode;
  final double price;
  final double cost;
  final int quantity;
  final String category; // Category ID reference
  final String? imageUrl;
  final bool isActive;
  final double vatRate; // VAT rate in percentage (e.g., 15 for 15%)
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync; // For offline sync

  Product({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.barcode,
    required this.price,
    required this.cost,
    this.quantity = 0,
    required this.category, // This is now categoryId
    this.imageUrl,
    this.isActive = true,
    this.vatRate = 15.0,
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = false,
  });

  double get priceWithVat => price * (1 + vatRate / 100);
  double get vatAmount => price * (vatRate / 100);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'barcode': barcode,
      'price': price,
      'cost': cost,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
      'isActive': isActive ? 1 : 0,
      'vatRate': vatRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'needsSync': needsSync ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      nameAr: map['nameAr'],
      description: map['description'],
      descriptionAr: map['descriptionAr'],
      barcode: map['barcode'],
      price: map['price'].toDouble(),
      cost: map['cost'].toDouble(),
      quantity: map['quantity'],
      category: map['category'],
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] == 1,
      vatRate: map['vatRate']?.toDouble() ?? 15.0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      needsSync: map['needsSync'] == 1,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? barcode,
    double? price,
    double? cost,
    int? quantity,
    String? category,
    String? imageUrl,
    bool? isActive,
    double? vatRate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      vatRate: vatRate ?? this.vatRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}
