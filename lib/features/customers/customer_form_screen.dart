import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/customer.dart';
import '../../providers/providers.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final Customer? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _picController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _companyController = TextEditingController(text: widget.customer?.companyName ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _picController = TextEditingController(text: widget.customer?.pic ?? '');
    _notesController = TextEditingController(text: widget.customer?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _picController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama customer harus diisi')));
      return;
    }
    final customer = Customer(
      id: widget.customer?.id,
      name: _nameController.text,
      companyName: _companyController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      pic: _picController.text,
      notes: _notesController.text,
    );
    final repo = ref.read(customerRepositoryProvider);
    if (widget.customer?.id != null) {
      await repo.update(customer);
    } else {
      await repo.insert(customer);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer != null ? 'Edit Customer' : 'Tambah Customer'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Customer *')),
            const SizedBox(height: 12),
            TextField(controller: _companyController, decoration: const InputDecoration(labelText: 'Nama Perusahaan')),
            const SizedBox(height: 12),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Alamat'), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Telepon'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextField(controller: _picController, decoration: const InputDecoration(labelText: 'PIC')),
            const SizedBox(height: 12),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Catatan'), maxLines: 3),
          ],
        ),
      ),
    );
  }
}
