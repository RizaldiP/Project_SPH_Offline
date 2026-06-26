class Customer {
  final int? id;
  final String name;
  final String? companyName;
  final String? address;
  final String? phone;
  final String? email;
  final String? pic;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Customer({
    this.id,
    required this.name,
    this.companyName,
    this.address,
    this.phone,
    this.email,
    this.pic,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'address': address,
      'phone': phone,
      'email': email,
      'pic': pic,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      companyName: map['company_name'] as String?,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      pic: map['pic'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? companyName,
    String? address,
    String? phone,
    String? email,
    String? pic,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      pic: pic ?? this.pic,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
