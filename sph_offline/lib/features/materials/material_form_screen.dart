import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/material.dart';
import '../../providers/providers.dart';

class MaterialFormScreen extends ConsumerStatefulWidget {
  final MaterialModel? material;
  const MaterialFormScreen({super.key, this.material});

  @override
  ConsumerState<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends ConsumerState<MaterialFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _unitController;
  late TextEditingController _priceController;
  late TextEditingController _supplierController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _categoryController = TextEditingController(text: widget.material?.category ?? '');
    _unitController = TextEditingController(text: widget.material?.unit ?? '');
    _priceController = TextEditingController(text: widget.material?.standardPrice.toString() ?? '');
    _supplierController = TextEditingController(text: widget.material?.supplier ?? '');
    _notesController = TextEditingController(text: widget.material?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama material harus diisi')));
      return;
    }
    final material = MaterialModel(
      id: widget.material?.id,
      name: _nameController.text,
      category: _categoryController.text,
      unit: _unitController.text,
      standardPrice: int.tryParse(_priceController.text.replaceAll('.', '')) ?? 0,
      supplier: _supplierController.text,
      notes: _notesController.text,
    );
    final repo = ref.read(materialRepositoryProvider);
    if (widget.material?.id != null) {
      await repo.update(material);
    } else {
      await repo.insert(material);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material != null ? 'Edit Material' : 'Tambah Material'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.save))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Material *')),
            const SizedBox(height: 12),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Kategori')),
            const SizedBox(height: 12),
            TextField(controller: _unitController, decoration: const InputDecoration(labelText: 'Satuan')),
            const SizedBox(height: 12),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Harga Standar'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _supplierController, decoration: const InputDecoration(labelText: 'Supplier')),
            const SizedBox(height: 12),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Catatan'), maxLines: 3),
          ],
        ),
      ),
    );
  }
}
