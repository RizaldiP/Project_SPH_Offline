class SphItem {
  final int? id;
  final int sphId;
  final String type;
  final String label;
  final int? parentId;
  final int sortOrder;
  final double qty;
  final String? unit;
  final double materialPrice;
  final double jasaPrice;
  final double unitPrice;
  final double totalPrice;

  SphItem({
    this.id,
    required this.sphId,
    required this.type,
    required this.label,
    this.parentId,
    this.sortOrder = 0,
    this.qty = 0,
    this.unit,
    this.materialPrice = 0,
    this.jasaPrice = 0,
    this.unitPrice = 0,
    this.totalPrice = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sph_id': sphId,
      'type': type,
      'label': label,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'qty': qty,
      'unit': unit,
      'material_price': materialPrice,
      'jasa_price': jasaPrice,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  factory SphItem.fromMap(Map<String, dynamic> map) {
    return SphItem(
      id: map['id'] as int?,
      sphId: map['sph_id'] as int,
      type: map['type'] as String,
      label: map['label'] as String,
      parentId: map['parent_id'] as int?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      qty: (map['qty'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String?,
      materialPrice: (map['material_price'] as num?)?.toDouble() ?? 0,
      jasaPrice: (map['jasa_price'] as num?)?.toDouble() ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
    );
  }

  SphItem copyWith({
    int? id,
    int? sphId,
    String? type,
    String? label,
    int? parentId,
    int? sortOrder,
    double? qty,
    String? unit,
    double? materialPrice,
    double? jasaPrice,
    double? unitPrice,
    double? totalPrice,
  }) {
    return SphItem(
      id: id ?? this.id,
      sphId: sphId ?? this.sphId,
      type: type ?? this.type,
      label: label ?? this.label,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      materialPrice: materialPrice ?? this.materialPrice,
      jasaPrice: jasaPrice ?? this.jasaPrice,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
