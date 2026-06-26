import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/template.dart';
import '../../providers/providers.dart';

class TemplateFormScreen extends ConsumerStatefulWidget {
  final SphTemplate? template;
  const TemplateFormScreen({super.key, this.template});

  @override
  ConsumerState<TemplateFormScreen> createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends ConsumerState<TemplateFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  List<_TemplateItemUI> _items = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _descController = TextEditingController(text: widget.template?.description ?? '');
    if (widget.template?.id != null) {
      _loadItems();
    }
  }

  void _loadItems() async {
    final items = await ref.read(templateRepositoryProvider).getItems(widget.template!.id!);
    setState(() {
      _items = items.map((item) => _TemplateItemUI(
        id: item.id,
        type: item.type,
        label: item.label,
        parentId: item.parentId,
        defaultUnit: item.defaultUnit,
      )).toList();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addSection() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Section'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nama Section'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _items.add(_TemplateItemUI(type: 'section', label: controller.text)));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _addItem(int sectionIndex) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Item'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nama Pekerjaan'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _items.add(_TemplateItemUI(
                  type: 'item',
                  label: controller.text,
                  parentId: _items[sectionIndex].id,
                )));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;
    final repo = ref.read(templateRepositoryProvider);
    if (widget.template?.id != null) {
      final updated = widget.template!.copyWith(name: _nameController.text, description: _descController.text);
      await repo.update(updated);
      await repo.deleteItemsByTemplateId(widget.template!.id!);
      for (int i = 0; i < _items.length; i++) {
        await repo.insertItem(TemplateItem(
          templateId: widget.template!.id!,
          type: _items[i].type,
          label: _items[i].label,
          parentId: _items[i].parentId,
          sortOrder: i,
          defaultUnit: _items[i].defaultUnit,
        ));
      }
    } else {
      final newId = await repo.insert(SphTemplate(name: _nameController.text, description: _descController.text));
      for (int i = 0; i < _items.length; i++) {
        await repo.insertItem(TemplateItem(
          templateId: newId,
          type: _items[i].type,
          label: _items[i].label,
          parentId: _items[i].parentId,
          sortOrder: i,
          defaultUnit: _items[i].defaultUnit,
        ));
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template != null ? 'Edit Template' : 'Tambah Template'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.save))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Template *')),
            const SizedBox(height: 12),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 2),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Item Pekerjaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addSection,
                  tooltip: 'Tambah Section',
                ),
              ],
            ),
            ..._items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  dense: true,
                  leading: Icon(item.type == 'section' ? Icons.folder : Icons.article, color: item.type == 'section' ? AppTheme.navyBlue : AppTheme.accent),
                  title: Text(item.label),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.type == 'section')
                        IconButton(icon: const Icon(Icons.add, size: 20), onPressed: () => _addItem(idx)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                        onPressed: () => setState(() => _items.removeAt(idx)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TemplateItemUI {
  final int? id;
  final String type;
  String label;
  final int? parentId;
  final String? defaultUnit;

  _TemplateItemUI({
    this.id,
    required this.type,
    required this.label,
    this.parentId,
    this.defaultUnit,
  });
}
