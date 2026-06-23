class MaterialModel {
  final int? id;
  final String name;
  final String? category;
  final String? unit;
  final double standardPrice;
  final String? supplier;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  MaterialModel({
    this.id,
    required this.name,
    this.category,
    this.unit,
    this.standardPrice = 0,
    this.supplier,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'standard_price': standardPrice,
      'supplier': supplier,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String?,
      unit: map['unit'] as String?,
      standardPrice: (map['standard_price'] as num?)?.toDouble() ?? 0,
      supplier: map['supplier'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  MaterialModel copyWith({
    int? id,
    String? name,
    String? category,
    String? unit,
    double? standardPrice,
    String? supplier,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      standardPrice: standardPrice ?? this.standardPrice,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
