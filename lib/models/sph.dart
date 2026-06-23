class Sph {
  final int? id;
  final String number;
  final String? title;
  final String? date;
  final int? customerId;
  final String? customerName;
  final String? customerCompany;
  final String? customerAddress;
  final String? customerPic;
  final String? shipName;
  final String? validityPeriod;
  final String? notes;
  final double discount;
  final double ppn;
  final String status;
  final double totalMaterial;
  final double totalJasa;
  final double subtotal;
  final double grandTotal;
  final String? createdAt;
  final String? updatedAt;

  Sph({
    this.id,
    required this.number,
    this.title,
    this.date,
    this.customerId,
    this.customerName,
    this.customerCompany,
    this.customerAddress,
    this.customerPic,
    this.shipName,
    this.validityPeriod,
    this.notes,
    this.discount = 0,
    this.ppn = 11,
    this.status = 'draft',
    this.totalMaterial = 0,
    this.totalJasa = 0,
    this.subtotal = 0,
    this.grandTotal = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'date': date,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_company': customerCompany,
      'customer_address': customerAddress,
      'customer_pic': customerPic,
      'ship_name': shipName,
      'validity_period': validityPeriod,
      'notes': notes,
      'discount': discount,
      'ppn': ppn,
      'status': status,
      'total_material': totalMaterial,
      'total_jasa': totalJasa,
      'subtotal': subtotal,
      'grand_total': grandTotal,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Sph.fromMap(Map<String, dynamic> map) {
    return Sph(
      id: map['id'] as int?,
      number: map['number'] as String,
      title: map['title'] as String?,
      date: map['date'] as String?,
      customerId: map['customer_id'] as int?,
      customerName: map['customer_name'] as String?,
      customerCompany: map['customer_company'] as String?,
      customerAddress: map['customer_address'] as String?,
      customerPic: map['customer_pic'] as String?,
      shipName: map['ship_name'] as String?,
      validityPeriod: map['validity_period'] as String?,
      notes: map['notes'] as String?,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      ppn: (map['ppn'] as num?)?.toDouble() ?? 11,
      status: map['status'] as String? ?? 'draft',
      totalMaterial: (map['total_material'] as num?)?.toDouble() ?? 0,
      totalJasa: (map['total_jasa'] as num?)?.toDouble() ?? 0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      grandTotal: (map['grand_total'] as num?)?.toDouble() ?? 0,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Sph copyWith({
    int? id,
    String? number,
    String? title,
    String? date,
    int? customerId,
    String? customerName,
    String? customerCompany,
    String? customerAddress,
    String? customerPic,
    String? shipName,
    String? validityPeriod,
    String? notes,
    double? discount,
    double? ppn,
    String? status,
    double? totalMaterial,
    double? totalJasa,
    double? subtotal,
    double? grandTotal,
    String? createdAt,
    String? updatedAt,
  }) {
    return Sph(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerCompany: customerCompany ?? this.customerCompany,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPic: customerPic ?? this.customerPic,
      shipName: shipName ?? this.shipName,
      validityPeriod: validityPeriod ?? this.validityPeriod,
      notes: notes ?? this.notes,
      discount: discount ?? this.discount,
      ppn: ppn ?? this.ppn,
      status: status ?? this.status,
      totalMaterial: totalMaterial ?? this.totalMaterial,
      totalJasa: totalJasa ?? this.totalJasa,
      subtotal: subtotal ?? this.subtotal,
      grandTotal: grandTotal ?? this.grandTotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
