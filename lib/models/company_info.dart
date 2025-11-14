class CompanyInfo {
  final String id;
  final String name;
  final String nameArabic;
  final String address;
  final String addressArabic;
  final String phone;
  final String? email;
  final String vatNumber;
  final String crnNumber;
  final String? logoPath;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyInfo({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.address,
    required this.addressArabic,
    required this.phone,
    this.email,
    required this.vatNumber,
    required this.crnNumber,
    this.logoPath,
    this.currency = 'SAR',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'address': address,
      'addressArabic': addressArabic,
      'phone': phone,
      'email': email,
      'vatNumber': vatNumber,
      'crnNumber': crnNumber,
      'logoPath': logoPath,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CompanyInfo.fromMap(Map<String, dynamic> map) {
    return CompanyInfo(
      id: map['id'],
      name: map['name'],
      nameArabic: map['nameArabic'],
      address: map['address'],
      addressArabic: map['addressArabic'],
      phone: map['phone'],
      email: map['email'],
      vatNumber: map['vatNumber'],
      crnNumber: map['crnNumber'],
      logoPath: map['logoPath'],
      currency: map['currency'] ?? 'SAR',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  CompanyInfo copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? address,
    String? addressArabic,
    String? phone,
    String? email,
    String? vatNumber,
    String? crnNumber,
    String? logoPath,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      address: address ?? this.address,
      addressArabic: addressArabic ?? this.addressArabic,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vatNumber: vatNumber ?? this.vatNumber,
      crnNumber: crnNumber ?? this.crnNumber,
      logoPath: logoPath ?? this.logoPath,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
