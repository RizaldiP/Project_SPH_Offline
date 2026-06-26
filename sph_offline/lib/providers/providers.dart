import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';
import '../models/material.dart';
import '../models/sph.dart';
import '../models/sph_item.dart';
import '../models/template.dart';
import '../models/company_settings.dart';
import '../services/customer_repository.dart';
import '../services/material_repository.dart';
import '../services/sph_repository.dart';
import '../services/template_repository.dart';
import '../services/settings_repository.dart';
import '../services/master_template_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository();
});

final sphRepositoryProvider = Provider<SphRepository>((ref) {
  return SphRepository();
});

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final masterTemplateRepositoryProvider = Provider<MasterTemplateRepository>((ref) {
  return MasterTemplateRepository();
});

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  return ref.read(customerRepositoryProvider).getAll();
});

final materialsProvider = FutureProvider<List<MaterialModel>>((ref) async {
  return ref.read(materialRepositoryProvider).getAll();
});

final templatesProvider = FutureProvider<List<SphTemplate>>((ref) async {
  return ref.read(templateRepositoryProvider).getAll();
});

final settingsProvider = FutureProvider<CompanySettings>((ref) async {
  return ref.read(settingsRepositoryProvider).get();
});

final masterTemplateProvider = FutureProvider<MasterTemplate?>((ref) async {
  return ref.read(masterTemplateRepositoryProvider).getActive();
});

final cellMappingsProvider = FutureProvider<List<CellMapping>>((ref) async {
  return ref.read(masterTemplateRepositoryProvider).getAllMappings();
});

final sphListProvider = FutureProvider.family<List<Sph>, String?>((ref, status) async {
  return ref.read(sphRepositoryProvider).getAll(status: status);
});

final sphDetailProvider = FutureProvider.family<Sph?, int>((ref, id) async {
  return ref.read(sphRepositoryProvider).getById(id);
});

final sphItemsProvider = FutureProvider.family<List<SphItem>, int>((ref, sphId) async {
  return ref.read(sphRepositoryProvider).getItems(sphId);
});

final templateItemsProvider = FutureProvider.family<List<TemplateItem>, int>((ref, templateId) async {
  return ref.read(templateRepositoryProvider).getItems(templateId);
});

class SphFormNotifier extends StateNotifier<SphFormState> {
  final SphRepository _sphRepo;
  final Ref _ref;

  SphFormNotifier(this._sphRepo, this._ref) : super(SphFormState());

  void reset() {
    state = SphFormState();
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDate(String v) => state = state.copyWith(date: v);
  void setCustomer(Customer? c) {
    state = state.copyWith(
      customerId: c?.id,
      customerName: c?.name,
      customerCompany: c?.companyName,
      customerAddress: c?.address,
      customerPic: c?.pic,
    );
  }
  void setShipName(String v) => state = state.copyWith(shipName: v);
  void setValidityPeriod(String v) => state = state.copyWith(validityPeriod: v);
  void setNotes(String v) => state = state.copyWith(notes: v);
  void setDiscount(double v) => state = state.copyWith(discount: v);
  void setPpn(double v) => state = state.copyWith(ppn: v);
  void setSph(Sph sph) {
    state = SphFormState(
      sphId: sph.id,
      number: sph.number,
      title: sph.title,
      date: sph.date,
      customerId: sph.customerId,
      customerName: sph.customerName,
      customerCompany: sph.customerCompany,
      customerAddress: sph.customerAddress,
      customerPic: sph.customerPic,
      shipName: sph.shipName,
      validityPeriod: sph.validityPeriod,
      notes: sph.notes,
      discount: sph.discount,
      ppn: sph.ppn,
      status: sph.status,
    );
  }

  void setItems(List<SphItem> items) {
    state = state.copyWith(items: items);
  }

  void addSection(String label) {
    final items = List<SphItem>.from(state.items);
    items.add(SphItem(
      sphId: state.sphId ?? 0,
      type: 'section',
      label: label,
      sortOrder: items.length,
    ));
    state = state.copyWith(items: items);
  }

  int addItem(int sectionIndex, String label) {
    final items = List<SphItem>.from(state.items);
    final section = items[sectionIndex];
    var insertAt = sectionIndex + 1;
    while (insertAt < items.length && items[insertAt].type == 'item') {
      insertAt++;
    }
    final newItem = SphItem(
      sphId: state.sphId ?? 0,
      type: 'item',
      label: label,
      parentId: section.id,
      sortOrder: items.length,
    );
    items.insert(insertAt, newItem);
    state = state.copyWith(items: items);
    return insertAt;
  }

  void updateItem(int index, SphItem item) {
    final items = List<SphItem>.from(state.items);
    items[index] = item;
    state = state.copyWith(items: items);
  }

  void removeItem(int index) {
    final items = List<SphItem>.from(state.items);
    items.removeAt(index);
    state = state.copyWith(items: items);
  }

  void reorder(int oldIndex, int newIndex) {
    final items = List<SphItem>.from(state.items);
    if (newIndex > oldIndex) newIndex--;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(sortOrder: i);
    }
    state = state.copyWith(items: items);
  }

  void calculateTotals() {
    int totalMaterial = 0;
    int totalJasa = 0;
    final items = List<SphItem>.from(state.items);
    for (int i = 0; i < items.length; i++) {
      if (items[i].type == 'item') {
        final unitPrice = items[i].materialPrice + items[i].jasaPrice;
        final totalPrice = (items[i].qty * unitPrice).round();
        items[i] = items[i].copyWith(unitPrice: unitPrice, totalPrice: totalPrice);
        totalMaterial += (items[i].materialPrice * items[i].qty).round();
        totalJasa += (items[i].jasaPrice * items[i].qty).round();
      }
    }
    final subtotal = totalMaterial + totalJasa;
    final discountAmount = (subtotal * (state.discount / 100)).round();
    final afterDiscount = subtotal - discountAmount;
    final ppnAmount = (afterDiscount * (state.ppn / 100)).round();
    final grandTotal = afterDiscount + ppnAmount;

    state = state.copyWith(
      items: items,
      totalMaterial: totalMaterial,
      totalJasa: totalJasa,
      subtotal: subtotal,
      grandTotal: grandTotal,
    );
  }

  Future<int?> save() async {
    calculateTotals();
    final now = DateTime.now().toIso8601String();
    final sph = Sph(
      id: state.sphId,
      number: state.number,
      title: state.title,
      date: state.date ?? DateTime.now().toIso8601String().substring(0, 10),
      customerId: state.customerId,
      customerName: state.customerName,
      customerCompany: state.customerCompany,
      customerAddress: state.customerAddress,
      customerPic: state.customerPic,
      shipName: state.shipName,
      validityPeriod: state.validityPeriod,
      notes: state.notes,
      discount: state.discount,
      ppn: state.ppn,
      status: state.status ?? 'draft',
      totalMaterial: state.totalMaterial,
      totalJasa: state.totalJasa,
      subtotal: state.subtotal,
      grandTotal: state.grandTotal,
      createdAt: now,
      updatedAt: now,
    );

    final int? savedId;
    if (state.sphId != null) {
      await _sphRepo.update(sph);
      await _sphRepo.deleteItemsBySphId(state.sphId!);
      for (int i = 0; i < state.items.length; i++) {
        await _sphRepo.insertItem(
          state.items[i].copyWith(sphId: state.sphId!, id: null, sortOrder: i),
        );
      }
      savedId = state.sphId;
    } else {
      final count = await _sphRepo.getCount();
      final newNumber = 'SPH-${DateTime.now().year}-${(count + 1).toString().padLeft(3, '0')}';
      final newSph = sph.copyWith(number: newNumber, id: null);
      final newId = await _sphRepo.insert(newSph);
      for (int i = 0; i < state.items.length; i++) {
        await _sphRepo.insertItem(
          state.items[i].copyWith(sphId: newId, id: null, sortOrder: i),
        );
      }
      savedId = newId;
    }

    _ref.invalidate(sphListProvider);

    // Auto-save to Work Template (sections with jasa items)
    await _autoSaveToTemplates();

    // Auto-save to Master Material (items with materialPrice > 0)
    await _autoSaveToMaterials();

    return savedId;
  }

  Future<void> _autoSaveToTemplates() async {
    final templateRepo = _ref.read(templateRepositoryProvider);
    final existingTemplates = await templateRepo.getAll();

    final items = state.items;
    var i = 0;
    while (i < items.length) {
      if (items[i].type == 'section') {
        final sectionLabel = items[i].label;
        i++;
        final jasaItems = <SphItem>[];
        while (i < items.length && items[i].type == 'item') {
          if (items[i].jasaPrice > 0) {
            jasaItems.add(items[i]);
          }
          i++;
        }
        if (jasaItems.isNotEmpty) {
          final candidateItemLabels = jasaItems.map((e) => e.label).toList();

          var isDuplicate = false;
          for (final existing in existingTemplates) {
            final existingItems = await templateRepo.getItems(existing.id!);
            final sectionItem = existingItems.isNotEmpty ? existingItems[0] : null;
            if (sectionItem == null || sectionItem.type != 'section') continue;
            if (sectionItem.label != sectionLabel) continue;
            final existingItemLabels = existingItems
                .where((e) => e.type == 'item')
                .map((e) => e.label)
                .toList();
            if (_listEquals(candidateItemLabels, existingItemLabels)) {
              isDuplicate = true;
              break;
            }
          }

          if (!isDuplicate) {
            var templateName = sectionLabel;
            var counter = 2;
            final existingNames = existingTemplates.map((t) => t.name).toSet();
            while (existingNames.contains(templateName)) {
              templateName = '$sectionLabel (#$counter)';
              counter++;
            }
            final newTemplateId = await templateRepo.insert(SphTemplate(name: templateName));
            await templateRepo.insertItem(TemplateItem(
              templateId: newTemplateId, type: 'section', label: sectionLabel, sortOrder: 0,
            ));
            for (int j = 0; j < jasaItems.length; j++) {
              await templateRepo.insertItem(TemplateItem(
                templateId: newTemplateId,
                type: 'item',
                label: jasaItems[j].label,
                sortOrder: j + 1,
                defaultUnit: jasaItems[j].unit,
              ));
            }
          }
        }
      } else {
        i++;
      }
    }
    _ref.invalidate(templatesProvider);
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _autoSaveToMaterials() async {
    final materialRepo = _ref.read(materialRepositoryProvider);
    for (final item in state.items) {
      if (item.type == 'item' && item.materialPrice > 0) {
        final existing = await materialRepo.getByName(item.label);
        if (existing != null) {
          await materialRepo.update(existing.copyWith(standardPrice: item.materialPrice));
        } else {
          await materialRepo.insert(MaterialModel(
            name: item.label,
            category: 'Material',
            unit: item.unit,
            standardPrice: item.materialPrice,
            supplier: '',
            notes: '',
          ));
        }
      }
    }
    _ref.invalidate(materialsProvider);
  }
}

class SphFormState {
  final int? sphId;
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
  final String? status;
  final int totalMaterial;
  final int totalJasa;
  final int subtotal;
  final int grandTotal;
  final List<SphItem> items;

  SphFormState({
    this.sphId,
    this.number = '',
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
    this.status,
    this.totalMaterial = 0,
    this.totalJasa = 0,
    this.subtotal = 0,
    this.grandTotal = 0,
    this.items = const [],
  });

  SphFormState copyWith({
    int? sphId,
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
    int? totalMaterial,
    int? totalJasa,
    int? subtotal,
    int? grandTotal,
    List<SphItem>? items,
  }) {
    return SphFormState(
      sphId: sphId ?? this.sphId,
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
      items: items ?? this.items,
    );
  }
}

final sphFormProvider = StateNotifierProvider<SphFormNotifier, SphFormState>((ref) {
  return SphFormNotifier(ref.read(sphRepositoryProvider), ref);
});
