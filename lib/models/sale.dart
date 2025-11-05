class Sale {
  final String id;
  final String invoiceNumber;
  final String? customerId;
  final String cashierId;
  final DateTime saleDate;
  final double subtotal;
  final double vatAmount;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final SaleStatus status;
  final PaymentMethod paymentMethod;
  final List<SaleItem> items;
  final String? notes;
  final bool isPrinted;
  final bool needsSync;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sale({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    required this.cashierId,
    required this.saleDate,
    required this.subtotal,
    required this.vatAmount,
    required this.totalAmount,
    required this.paidAmount,
    this.changeAmount = 0.0,
    this.status = SaleStatus.completed,
    this.paymentMethod = PaymentMethod.cash,
    required this.items,
    this.notes,
    this.isPrinted = false,
    this.needsSync = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'cashierId': cashierId,
      'saleDate': saleDate.toIso8601String(),
      'subtotal': subtotal,
      'vatAmount': vatAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
      'status': status.toString(),
      'paymentMethod': paymentMethod.toString(),
      'notes': notes,
      'isPrinted': isPrinted ? 1 : 0,
      'needsSync': needsSync ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, List<SaleItem> items) {
    return Sale(
      id: map['id'],
      invoiceNumber: map['invoiceNumber'],
      customerId: map['customerId'],
      cashierId: map['cashierId'],
      saleDate: DateTime.parse(map['saleDate']),
      subtotal: map['subtotal'].toDouble(),
      vatAmount: map['vatAmount'].toDouble(),
      totalAmount: map['totalAmount'].toDouble(),
      paidAmount: map['paidAmount'].toDouble(),
      changeAmount: map['changeAmount']?.toDouble() ?? 0.0,
      status: SaleStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == map['paymentMethod'],
      ),
      items: items,
      notes: map['notes'],
      isPrinted: map['isPrinted'] == 1,
      needsSync: map['needsSync'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Sale copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? cashierId,
    DateTime? saleDate,
    double? subtotal,
    double? vatAmount,
    double? totalAmount,
    double? paidAmount,
    double? changeAmount,
    SaleStatus? status,
    PaymentMethod? paymentMethod,
    List<SaleItem>? items,
    String? notes,
    bool? isPrinted,
    bool? needsSync,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sale(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      cashierId: cashierId ?? this.cashierId,
      saleDate: saleDate ?? this.saleDate,
      subtotal: subtotal ?? this.subtotal,
      vatAmount: vatAmount ?? this.vatAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      isPrinted: isPrinted ?? this.isPrinted,
      needsSync: needsSync ?? this.needsSync,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SaleItem {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double vatRate;
  final double vatAmount;
  final double subtotal;
  final double total;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.vatRate,
    required this.vatAmount,
    required this.subtotal,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'vatRate': vatRate,
      'vatAmount': vatAmount,
      'subtotal': subtotal,
      'total': total,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['saleId'],
      productId: map['productId'],
      productName: map['productName'],
      unitPrice: map['unitPrice'].toDouble(),
      quantity: map['quantity'],
      vatRate: map['vatRate'].toDouble(),
      vatAmount: map['vatAmount'].toDouble(),
      subtotal: map['subtotal'].toDouble(),
      total: map['total'].toDouble(),
    );
  }
}

enum SaleStatus {
  completed,
  returned,
  cancelled,
}

enum PaymentMethod {
  cash,
  card,
  transfer,
}
