class CompanySettings {
  final int id;
  final String? companyName;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoPath;
  final String? signaturePath;
  final String? stampPath;
  final String? npwp;
  final String defaultPpn;
  final String sphNumberFormat;
  final String currency;
  final String? signatureName;
  final String? signaturePosition;
  final String? notes;

  CompanySettings({
    this.id = 0,
    this.companyName,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logoPath,
    this.signaturePath,
    this.stampPath,
    this.npwp,
    this.defaultPpn = '11',
    this.sphNumberFormat = 'SPH-YYYY-NNN',
    this.currency = 'Rp',
    this.signatureName,
    this.signaturePosition,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_name': companyName,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'logo_path': logoPath,
      'signature_path': signaturePath,
      'stamp_path': stampPath,
      'npwp': npwp,
      'default_ppn': defaultPpn,
      'sph_number_format': sphNumberFormat,
      'currency': currency,
      'signature_name': signatureName,
      'signature_position': signaturePosition,
      'notes': notes,
    };
  }

  factory CompanySettings.fromMap(Map<String, dynamic> map) {
    return CompanySettings(
      id: map['id'] as int? ?? 0,
      companyName: map['company_name'] as String?,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      logoPath: map['logo_path'] as String?,
      signaturePath: map['signature_path'] as String?,
      stampPath: map['stamp_path'] as String?,
      npwp: map['npwp'] as String?,
      defaultPpn: map['default_ppn'] as String? ?? '11',
      sphNumberFormat: map['sph_number_format'] as String? ?? 'SPH-YYYY-NNN',
      currency: map['currency'] as String? ?? 'Rp',
      signatureName: map['signature_name'] as String?,
      signaturePosition: map['signature_position'] as String?,
      notes: map['notes'] as String?,
    );
  }

  CompanySettings copyWith({
    int? id,
    String? companyName,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logoPath,
    String? signaturePath,
    String? stampPath,
    String? npwp,
    String? defaultPpn,
    String? sphNumberFormat,
    String? currency,
    String? signatureName,
    String? signaturePosition,
    String? notes,
  }) {
    return CompanySettings(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoPath: logoPath ?? this.logoPath,
      signaturePath: signaturePath ?? this.signaturePath,
      stampPath: stampPath ?? this.stampPath,
      npwp: npwp ?? this.npwp,
      defaultPpn: defaultPpn ?? this.defaultPpn,
      sphNumberFormat: sphNumberFormat ?? this.sphNumberFormat,
      currency: currency ?? this.currency,
      signatureName: signatureName ?? this.signatureName,
      signaturePosition: signaturePosition ?? this.signaturePosition,
      notes: notes ?? this.notes,
    );
  }
}
