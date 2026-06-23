import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/sph_item.dart';
import '../../models/template.dart';
import '../../providers/providers.dart';
import '../customers/customer_picker_screen.dart';
import 'sph_item_edit_dialog.dart';

class SphFormScreen extends ConsumerStatefulWidget {
  final int? sphId;
  const SphFormScreen({super.key, this.sphId});

  @override
  ConsumerState<SphFormScreen> createState() => _SphFormScreenState();
}

class _SphFormScreenState extends ConsumerState<SphFormScreen> {
  final _titleController = TextEditingController();
  final _shipNameController = TextEditingController();
  final _validityController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController();
  final _ppnController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final Set<int> _collapsed = {};

  @override
  void initState() {
    super.initState();
    if (widget.sphId != null) {
      _loadSph();
    } else {
      ref.read(sphFormProvider.notifier).reset();
    }
    _ppnController.text = '11';
  }

  void _loadSph() async {
    final sph = await ref.read(sphRepositoryProvider).getById(widget.sphId!);
    if (sph != null && mounted) {
      ref.read(sphFormProvider.notifier).setSph(sph);
      _titleController.text = sph.title ?? '';
      _shipNameController.text = sph.shipName ?? '';
      _validityController.text = sph.validityPeriod ?? '';
      _notesController.text = sph.notes ?? '';
      _discountController.text = sph.discount.toString();
      _ppnController.text = sph.ppn.toString();
      if (sph.date != null) {
        _selectedDate = DateTime.parse(sph.date!);
      }
      final items = await ref.read(sphRepositoryProvider).getItems(widget.sphId!);
      ref.read(sphFormProvider.notifier).setItems(items);
    }
  }

  String _computeNumber(List<SphItem> items, int index) {
    var sectionCount = 0;
    var itemCount = 0;
    for (var i = 0; i <= index; i++) {
      if (items[i].type == 'section') {
        sectionCount++;
        itemCount = 0;
      } else if (items[i].type == 'item') {
        itemCount++;
      }
    }
    if (items[index].type == 'section') {
      return '${_toRoman(sectionCount)}.';
    }
    return '${_toLetter(itemCount - 1)}.';
  }

  bool _isParentCollapsed(List<SphItem> items, int index) {
    for (var i = index - 1; i >= 0; i--) {
      if (items[i].type == 'section') {
        return _collapsed.contains(i);
      }
    }
    return false;
  }

  void _showImportTemplateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _TemplateImportDialog(
        onImport: (items) {
          for (final item in items) {
            ref.read(sphFormProvider.notifier).addSection(item.label);
            for (final child in item.children) {
              ref.read(sphFormProvider.notifier).addItem(
                ref.read(sphFormProvider).items.length - 1,
                child,
              );
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shipNameController.dispose();
    _validityController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    _ppnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(sphFormProvider);
    final formNotifier = ref.read(sphFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sphId != null ? 'Edit SPH' : 'Buat SPH Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              formNotifier.setTitle(_titleController.text);
              formNotifier.setShipName(_shipNameController.text);
              formNotifier.setValidityPeriod(_validityController.text);
              formNotifier.setNotes(_notesController.text);
              formNotifier.setDiscount(double.tryParse(_discountController.text.replaceAll(',', '.')) ?? 0);
              formNotifier.setPpn(double.tryParse(_ppnController.text.replaceAll(',', '.')) ?? 11);
              final id = await formNotifier.save();
              if (mounted && id != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SPH berhasil disimpan')),
                );
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi SPH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Perihal'),
                      onChanged: (v) => formNotifier.setTitle(v),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(formState.customerName ?? 'Pilih Customer'),
                      subtitle: Text(formState.customerCompany ?? ''),
                      leading: const Icon(Icons.person),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final customer = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CustomerPickerScreen()),
                        );
                        if (customer != null) {
                          formNotifier.setCustomer(customer);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _shipNameController,
                      decoration: const InputDecoration(labelText: 'Nama Kapal (Opsional)'),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (date != null) {
                          _selectedDate = date;
                          formNotifier.setDate(date.toIso8601String().substring(0, 10));
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Tanggal'),
                        child: Text(Helpers.formatDate(_selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _validityController,
                      decoration: const InputDecoration(labelText: 'Masa Berlaku Penawaran'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Catatan Tambahan'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Item Pekerjaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.library_books_outlined),
                              onPressed: () => _showImportTemplateDialog(),
                              tooltip: 'Ambil dari Template',
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _showAddSectionDialog(context),
                              tooltip: 'Tambah Section',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (formState.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Belum ada item. Tambahkan section pekerjaan.', style: TextStyle(color: AppTheme.darkGray)),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: formState.items.length,
                        onReorderItem: (oldIndex, newIndex) {
                          formNotifier.reorder(oldIndex, newIndex);
                          setState(() {});
                        },
                        proxyDecorator: (child, index, animation) => Material(elevation: 2, child: child),
                        itemBuilder: (context, index) {
                          final item = formState.items[index];
                          final isCollapsed = _collapsed.contains(index);
                          final numberPrefix = _computeNumber(formState.items, index);
                          if (item.type == 'item' && _isParentCollapsed(formState.items, index)) {
                            return const SizedBox.shrink();
                          }
                          return _SphItemCard(
                            key: ValueKey(item.sortOrder),
                            numberPrefix: numberPrefix,
                            item: item,
                            index: index,
                            isCollapsed: isCollapsed,
                            onToggleCollapse: item.type == 'section'
                                ? () => setState(() {
                                      if (isCollapsed) {
                                        _collapsed.remove(index);
                                      } else {
                                        _collapsed.add(index);
                                      }
                                    })
                                : null,
                            onEdit: () => _editItem(index),
                            onDelete: () => formNotifier.removeItem(index),
                            onAddSubItem: item.type == 'section'
                                ? () => _showAddItemDialog(context, index)
                                : null,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rekap Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _TotalRow(label: 'Total Material', value: Helpers.formatCurrency(formState.totalMaterial)),
                    _TotalRow(label: 'Total Jasa', value: Helpers.formatCurrency(formState.totalJasa)),
                    const Divider(),
                    _TotalRow(label: 'Subtotal', value: Helpers.formatCurrency(formState.subtotal)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(child: Text('Diskon (%)', style: TextStyle(fontSize: 14))),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                            onChanged: (v) {
                              formNotifier.setDiscount(double.tryParse(v.replaceAll(',', '.')) ?? 0);
                              formNotifier.calculateTotals();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(child: Text('PPN (%)', style: TextStyle(fontSize: 14))),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _ppnController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                            onChanged: (v) {
                              formNotifier.setPpn(double.tryParse(v.replaceAll(',', '.')) ?? 11);
                              formNotifier.calculateTotals();
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _TotalRow(label: 'Grand Total', value: Helpers.formatCurrency(formState.grandTotal), bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAddSectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Section'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nama Section'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(sphFormProvider.notifier).addSection(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, int sectionIndex) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Item Pekerjaan'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nama Pekerjaan'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(sphFormProvider.notifier).addItem(sectionIndex, controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _editItem(int index) async {
    final item = ref.read(sphFormProvider).items[index];
    final result = await showDialog<SphItem>(
      context: context,
      builder: (ctx) => SphItemEditDialog(item: item),
    );
    if (result != null) {
      ref.read(sphFormProvider.notifier).updateItem(index, result);
      ref.read(sphFormProvider.notifier).calculateTotals();
    }
  }
}

String _toRoman(int n) {
  const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const symbols = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
  var result = '';
  var num = n;
  for (var i = 0; i < values.length; i++) {
    while (num >= values[i]) {
      result += symbols[i];
      num -= values[i];
    }
  }
  return result;
}

String _toLetter(int n) {
  const letters = 'abcdefghijklmnopqrstuvwxyz';
  if (n < 26) return letters[n];
  return '${letters[n ~/ 26 - 1]}${letters[n % 26]}';
}

class _SphItemCard extends StatelessWidget {
  final SphItem item;
  final int index;
  final String numberPrefix;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddSubItem;

  const _SphItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.numberPrefix,
    this.isCollapsed = false,
    this.onToggleCollapse,
    required this.onEdit,
    required this.onDelete,
    this.onAddSubItem,
  });

  @override
  Widget build(BuildContext context) {
    final isSection = item.type == 'section';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: EdgeInsets.only(
          left: isSection ? 8 : 24,
          right: 8,
          top: 6,
          bottom: 6,
        ),
        child: Row(
          children: [
            if (isSection)
              GestureDetector(
                onTap: onToggleCollapse,
                child: Icon(
                  isCollapsed ? Icons.arrow_right : Icons.expand_more,
                  size: 20,
                  color: AppTheme.navyBlue,
                ),
              ),
            Icon(
              isSection ? Icons.folder : Icons.article,
              size: 18,
              color: isSection ? AppTheme.navyBlue : AppTheme.accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$numberPrefix ${item.label}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: isSection ? AppTheme.navyBlue : null,
                      )),
                  if (!isSection)
                    Text(
                      '${item.qty} ${item.unit ?? ""} | Mat: ${Helpers.formatCurrency(item.materialPrice)} Jasa: ${Helpers.formatCurrency(item.jasaPrice)} = ${Helpers.formatCurrency(item.totalPrice)}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.darkGray),
                    ),
                ],
              ),
            ),
            if (onAddSubItem != null)
              SizedBox(
                width: 28, height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: onAddSubItem,
                ),
              ),
            SizedBox(
              width: 28, height: 28,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit, size: 18),
                onPressed: onEdit,
              ),
            ),
            SizedBox(
              width: 28, height: 28,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                onPressed: onDelete,
              ),
            ),
            ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle, size: 20)),
          ],
        ),
      ),
    );
  }
}

class _TemplateImportDialog extends ConsumerWidget {
  final void Function(List<_TemplateSectionImport> onImport) onImport;
  const _TemplateImportDialog({required this.onImport});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);
    return AlertDialog(
      title: const Text('Ambil dari Template'),
      content: SizedBox(
        width: double.maxFinite,
        child: templatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return const Text('Belum ada template.');
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: templates.length,
              itemBuilder: (ctx, i) {
                final template = templates[i];
                return ListTile(
                  title: Text(template.name),
                  subtitle: template.description != null && template.description!.isNotEmpty
                      ? Text(template.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final items = await ref.read(templateRepositoryProvider).getItems(template.id!);
                    if (!context.mounted) return;
                    _showTemplateDetailDialog(context, template.name, items);
                  },
                );
              },
            );
          },
          error: (_, _) => const Text('Gagal memuat template'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
      ],
    );
  }

  void _showTemplateDetailDialog(BuildContext context, String name, List<TemplateItem> items) {
    final sections = <_TemplateSectionImport>[];
    _TemplateSectionImport? currentSection;
    for (final item in items) {
      if (item.type == 'section') {
        currentSection = _TemplateSectionImport(label: item.label);
        sections.add(currentSection);
      } else if (item.type == 'item' && currentSection != null) {
        currentSection.children.add(item.label);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => _TemplateSectionPickerDialog(
        templateName: name,
        sections: sections,
        onConfirm: () {
          final selected = sections.where((s) => s.selected).toList();
          if (selected.isNotEmpty) {
            Navigator.pop(ctx);
            Navigator.pop(context);
            onImport(selected);
          }
        },
      ),
    );
  }
}

class _TemplateSectionPickerDialog extends StatefulWidget {
  final String templateName;
  final List<_TemplateSectionImport> sections;
  final VoidCallback onConfirm;
  const _TemplateSectionPickerDialog({
    required this.templateName,
    required this.sections,
    required this.onConfirm,
  });

  @override
  State<_TemplateSectionPickerDialog> createState() => _TemplateSectionPickerDialogState();
}

class _TemplateSectionPickerDialogState extends State<_TemplateSectionPickerDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.templateName} - Pilih Section'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.sections.length,
          itemBuilder: (ctx, i) {
            final section = widget.sections[i];
            return CheckboxListTile(
              title: Text(section.label),
              subtitle: Text('${section.children.length} item'),
              value: section.selected,
              onChanged: (v) => setState(() => section.selected = v ?? false),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: widget.onConfirm, child: const Text('Import')),
      ],
    );
  }
}

class _TemplateSectionImport {
  final String label;
  final List<String> children;
  bool selected;
  _TemplateSectionImport({required this.label, List<String>? children})
      : selected = true, children = children ?? [];
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TotalRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? AppTheme.navyBlue : null)),
        ],
      ),
    );
  }
}
