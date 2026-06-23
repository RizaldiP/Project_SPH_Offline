class SphTemplate {
  final int? id;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  SphTemplate({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory SphTemplate.fromMap(Map<String, dynamic> map) {
    return SphTemplate(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  SphTemplate copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return SphTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TemplateItem {
  final int? id;
  final int templateId;
  final String type;
  final String label;
  final int? parentId;
  final int sortOrder;
  final String? defaultUnit;

  TemplateItem({
    this.id,
    required this.templateId,
    required this.type,
    required this.label,
    this.parentId,
    this.sortOrder = 0,
    this.defaultUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template_id': templateId,
      'type': type,
      'label': label,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'default_unit': defaultUnit,
    };
  }

  factory TemplateItem.fromMap(Map<String, dynamic> map) {
    return TemplateItem(
      id: map['id'] as int?,
      templateId: map['template_id'] as int,
      type: map['type'] as String,
      label: map['label'] as String,
      parentId: map['parent_id'] as int?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      defaultUnit: map['default_unit'] as String?,
    );
  }
}
