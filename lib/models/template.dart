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

  TemplateItem copyWith({
    int? id,
    int? templateId,
    String? type,
    String? label,
    int? parentId,
    int? sortOrder,
    String? defaultUnit,
  }) {
    return TemplateItem(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      type: type ?? this.type,
      label: label ?? this.label,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      defaultUnit: defaultUnit ?? this.defaultUnit,
    );
  }
}

class MasterTemplate {
  final int? id;
  final String fileName;
  final String filePath;
  final String? sheetName;
  final int isActive;
  final String? createdAt;
  final String? updatedAt;

  MasterTemplate({
    this.id,
    required this.fileName,
    required this.filePath,
    this.sheetName,
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'sheet_name': sheetName,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MasterTemplate.fromMap(Map<String, dynamic> map) {
    return MasterTemplate(
      id: map['id'] as int?,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      sheetName: map['sheet_name'] as String?,
      isActive: (map['is_active'] as num?)?.toInt() ?? 1,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  MasterTemplate copyWith({
    int? id,
    String? fileName,
    String? filePath,
    String? sheetName,
    int? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return MasterTemplate(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      sheetName: sheetName ?? this.sheetName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CellMapping {
  final int? id;
  final String fieldName;
  final String? cellAddress;
  final int isTableField;
  final int? tableStartRow;
  final String? tableColumn;
  final int? prototypeRow;

  CellMapping({
    this.id,
    required this.fieldName,
    this.cellAddress,
    this.isTableField = 0,
    this.tableStartRow,
    this.tableColumn,
    this.prototypeRow,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'field_name': fieldName,
      'cell_address': cellAddress,
      'is_table_field': isTableField,
      'table_start_row': tableStartRow,
      'table_column': tableColumn,
      'prototype_row': prototypeRow,
    };
  }

  factory CellMapping.fromMap(Map<String, dynamic> map) {
    return CellMapping(
      id: map['id'] as int?,
      fieldName: map['field_name'] as String,
      cellAddress: map['cell_address'] as String?,
      isTableField: (map['is_table_field'] as num?)?.toInt() ?? 0,
      tableStartRow: map['table_start_row'] as int?,
      tableColumn: map['table_column'] as String?,
      prototypeRow: map['prototype_row'] as int?,
    );
  }

  CellMapping copyWith({
    int? id,
    String? fieldName,
    String? cellAddress,
    int? isTableField,
    int? tableStartRow,
    String? tableColumn,
    int? prototypeRow,
  }) {
    return CellMapping(
      id: id ?? this.id,
      fieldName: fieldName ?? this.fieldName,
      cellAddress: cellAddress ?? this.cellAddress,
      isTableField: isTableField ?? this.isTableField,
      tableStartRow: tableStartRow ?? this.tableStartRow,
      tableColumn: tableColumn ?? this.tableColumn,
      prototypeRow: prototypeRow ?? this.prototypeRow,
    );
  }
}
