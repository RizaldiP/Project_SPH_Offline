import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _npwpController;
  late TextEditingController _ppnController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _websiteController = TextEditingController();
    _npwpController = TextEditingController();
    _ppnController = TextEditingController(text: '11');
    _load();
  }

  void _load() async {
    final settings = await ref.read(settingsRepositoryProvider).get();
    _nameController.text = settings.companyName ?? '';
    _addressController.text = settings.address ?? '';
    _phoneController.text = settings.phone ?? '';
    _emailController.text = settings.email ?? '';
    _websiteController.text = settings.website ?? '';
    _npwpController.text = settings.npwp ?? '';
    _ppnController.text = settings.defaultPpn;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _npwpController.dispose();
    _ppnController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(settingsRepositoryProvider);
    final current = await repo.get();
    await repo.update(current.copyWith(
      companyName: _nameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      website: _websiteController.text,
      npwp: _npwpController.text,
      defaultPpn: _ppnController.text,
    ));
    ref.invalidate(settingsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan berhasil disimpan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data Perusahaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Perusahaan')),
            const SizedBox(height: 12),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Alamat'), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Telepon'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextField(controller: _websiteController, decoration: const InputDecoration(labelText: 'Website')),
            const SizedBox(height: 12),
            TextField(controller: _npwpController, decoration: const InputDecoration(labelText: 'NPWP (Opsional)')),
            const SizedBox(height: 24),
            const Text('Pengaturan Default', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _ppnController,
              decoration: const InputDecoration(labelText: 'PPN Default (%)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            const Text('Logo & Tanda Tangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.image, color: AppTheme.navyBlue),
                title: const Text('Logo Perusahaan'),
                subtitle: const Text('Tap untuk mengganti'),
                trailing: const Icon(Icons.upload),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur akan datang di update berikutnya')));
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.draw, color: AppTheme.navyBlue),
                title: const Text('Tanda Tangan Digital'),
                subtitle: const Text('Tap untuk mengganti'),
                trailing: const Icon(Icons.upload),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur akan datang di update berikutnya')));
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.stacked_bar_chart, color: AppTheme.navyBlue),
                title: const Text('Stempel Digital'),
                subtitle: const Text('Tap untuk mengganti'),
                trailing: const Icon(Icons.upload),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur akan datang di update berikutnya')));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
