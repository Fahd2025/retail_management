class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;

  // Saudi-specific fields
  final String? crnNumber; // Commercial Registration Number
  final String? vatNumber;
  final SaudiAddress? saudiAddress;

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.crnNumber,
    this.vatNumber,
    this.saudiAddress,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'crnNumber': crnNumber,
      'vatNumber': vatNumber,
      'saudiAddress': saudiAddress?.toJson(),
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'needsSync': needsSync ? 1 : 0,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      crnNumber: map['crnNumber'],
      vatNumber: map['vatNumber'],
      saudiAddress: map['saudiAddress'] != null
          ? SaudiAddress.fromJson(map['saudiAddress'])
          : null,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      needsSync: map['needsSync'] == 1,
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? crnNumber,
    String? vatNumber,
    SaudiAddress? saudiAddress,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      crnNumber: crnNumber ?? this.crnNumber,
      vatNumber: vatNumber ?? this.vatNumber,
      saudiAddress: saudiAddress ?? this.saudiAddress,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}

class SaudiAddress {
  final String? buildingNumber;
  final String? streetName;
  final String? district;
  final String? city;
  final String? postalCode;
  final String? additionalNumber;

  SaudiAddress({
    this.buildingNumber,
    this.streetName,
    this.district,
    this.city,
    this.postalCode,
    this.additionalNumber,
  });

  String toJson() {
    return '${buildingNumber ?? ''}|${streetName ?? ''}|${district ?? ''}|${city ?? ''}|${postalCode ?? ''}|${additionalNumber ?? ''}';
  }

  factory SaudiAddress.fromJson(String json) {
    final parts = json.split('|');
    return SaudiAddress(
      buildingNumber: parts.isNotEmpty ? parts[0] : null,
      streetName: parts.length > 1 ? parts[1] : null,
      district: parts.length > 2 ? parts[2] : null,
      city: parts.length > 3 ? parts[3] : null,
      postalCode: parts.length > 4 ? parts[4] : null,
      additionalNumber: parts.length > 5 ? parts[5] : null,
    );
  }

  // Alias for fromJson (used by Drift database)
  factory SaudiAddress.fromString(String str) => SaudiAddress.fromJson(str);

  String get formattedAddress {
    final parts = <String>[];
    if (buildingNumber?.isNotEmpty ?? false)
      parts.add('Building: $buildingNumber');
    if (streetName?.isNotEmpty ?? false) parts.add(streetName!);
    if (district?.isNotEmpty ?? false) parts.add(district!);
    if (city?.isNotEmpty ?? false) parts.add(city!);
    if (postalCode?.isNotEmpty ?? false) parts.add('Postal: $postalCode');
    return parts.join(', ');
  }
}
