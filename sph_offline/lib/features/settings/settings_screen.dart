import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'master_template_screen.dart';

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
  late TextEditingController _signNameController;
  late TextEditingController _signPositionController;
  late TextEditingController _notesController;

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
    _signNameController = TextEditingController();
    _signPositionController = TextEditingController();
    _notesController = TextEditingController();
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
    _signNameController.text = settings.signatureName ?? '';
    _signPositionController.text = settings.signaturePosition ?? '';
    _notesController.text = settings.notes ?? '';
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
    _signNameController.dispose();
    _signPositionController.dispose();
    _notesController.dispose();
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
      signatureName: _signNameController.text,
      signaturePosition: _signPositionController.text,
      notes: _notesController.text,
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
            const Text('Tanda Tangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _signNameController, decoration: const InputDecoration(labelText: 'Nama Penanggung Jawab')),
            const SizedBox(height: 12),
            TextField(controller: _signPositionController, decoration: const InputDecoration(labelText: 'Jabatan')),
            const SizedBox(height: 24),
            const Text('Pengaturan Default', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _ppnController,
              decoration: const InputDecoration(labelText: 'PPN Default (%)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Catatan Penawaran (default)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text('Template & Ekspor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description, color: AppTheme.navyBlue),
                title: const Text('Master Template'),
                subtitle: const Text('Atur template Excel & posisi data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const MasterTemplateScreen(),
                  ));
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Logo & Tanda Tangan Digital', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.image, color: AppTheme.navyBlue),
                title: const Text('Logo Perusahaan'),
                subtitle: const Text('Tap untuk mengganti'),
                trailing: const Icon(Icons.upload),
                onTap: () async {
                  final result = await _pickImage();
                  if (result != null) {
                    final repo = ref.read(settingsRepositoryProvider);
                    final current = await repo.get();
                    await repo.update(current.copyWith(logoPath: result));
                    ref.invalidate(settingsProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo berhasil diperbarui')));
                    }
                  }
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.draw, color: AppTheme.navyBlue),
                title: const Text('Tanda Tangan Digital'),
                subtitle: const Text('Tap untuk mengganti'),
                trailing: const Icon(Icons.upload),
                onTap: () async {
                  final result = await _pickImage();
                  if (result != null) {
                    final repo = ref.read(settingsRepositoryProvider);
                    final current = await repo.get();
                    await repo.update(current.copyWith(signaturePath: result));
                    ref.invalidate(settingsProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanda tangan berhasil diperbarui')));
                    }
                  }
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.stacked_bar_chart, color: AppTheme.navyBlue),
                title: const Text('Stempel Digital'),
                subtitle: const Text('Tap untuk mengganti'),
                trailing: const Icon(Icons.upload),
                onTap: () async {
                  final result = await _pickImage();
                  if (result != null) {
                    final repo = ref.read(settingsRepositoryProvider);
                    final current = await repo.get();
                    await repo.update(current.copyWith(stampPath: result));
                    ref.invalidate(settingsProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stempel berhasil diperbarui')));
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final result = await imagePicker.pickImage(source: ImageSource.gallery);
      if (result == null) return null;
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = result.name;
      final destPath = '${appDir.path}/$fileName';
      await File(result.path).copy(destPath);
      return destPath;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
      return null;
    }
  }
}
