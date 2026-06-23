import 'package:flutter/material.dart';
import '../../models/sph_item.dart';

class SphItemEditDialog extends StatefulWidget {
  final SphItem item;
  const SphItemEditDialog({super.key, required this.item});

  @override
  State<SphItemEditDialog> createState() => _SphItemEditDialogState();
}

class _SphItemEditDialogState extends State<SphItemEditDialog> {
  late TextEditingController _labelController;
  late TextEditingController _qtyController;
  late TextEditingController _unitController;
  late TextEditingController _materialController;
  late TextEditingController _jasaController;
  late TextEditingController _unitPriceController;
  late TextEditingController _totalController;
  bool _manualMode = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.item.label);
    _qtyController = TextEditingController(text: widget.item.qty > 0 ? widget.item.qty.toString() : '');
    _unitController = TextEditingController(text: widget.item.unit ?? '');
    _materialController = TextEditingController(text: widget.item.materialPrice > 0 ? widget.item.materialPrice.toString() : '');
    _jasaController = TextEditingController(text: widget.item.jasaPrice > 0 ? widget.item.jasaPrice.toString() : '');
    _unitPriceController = TextEditingController(text: widget.item.unitPrice > 0 ? widget.item.unitPrice.toString() : '');
    _totalController = TextEditingController(text: widget.item.totalPrice > 0 ? widget.item.totalPrice.toString() : '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    _materialController.dispose();
    _jasaController.dispose();
    _unitPriceController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSection = widget.item.type == 'section';

    return AlertDialog(
      title: Text(isSection ? 'Edit Section' : 'Edit Item Pekerjaan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              decoration: InputDecoration(labelText: isSection ? 'Nama Section' : 'Uraian Pekerjaan'),
            ),
            if (!isSection) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      decoration: const InputDecoration(labelText: 'Qty'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'Satuan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Mode Manual'),
                  Switch(
                    value: _manualMode,
                    onChanged: (v) => setState(() => _manualMode = v),
                  ),
                ],
              ),
              if (!_manualMode) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _materialController,
                  decoration: const InputDecoration(labelText: 'Harga Material'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _jasaController,
                  decoration: const InputDecoration(labelText: 'Harga Jasa'),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _unitPriceController,
                  decoration: const InputDecoration(labelText: 'Harga Satuan'),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _totalController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            final qty = double.tryParse(_qtyController.text.replaceAll(',', '.')) ?? 0;
            final material = double.tryParse(_materialController.text.replaceAll(',', '.')) ?? 0;
            final jasa = double.tryParse(_jasaController.text.replaceAll(',', '.')) ?? 0;
            final unitPrice = double.tryParse(_unitPriceController.text.replaceAll(',', '.')) ?? 0;
            final total = double.tryParse(_totalController.text.replaceAll(',', '.')) ?? 0;

            final updated = widget.item.copyWith(
              label: _labelController.text,
              qty: qty,
              unit: _unitController.text,
              materialPrice: _manualMode ? 0 : material,
              jasaPrice: _manualMode ? 0 : jasa,
              unitPrice: _manualMode ? unitPrice : (material + jasa),
              totalPrice: total > 0 ? total : qty * (_manualMode ? unitPrice : (material + jasa)),
            );

            Navigator.pop(context, updated);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
