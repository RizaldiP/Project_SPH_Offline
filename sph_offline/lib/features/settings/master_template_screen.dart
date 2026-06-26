import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel_lib;
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/template.dart';
import 'cell_mapping_screen.dart';

class MasterTemplateScreen extends ConsumerStatefulWidget {
  const MasterTemplateScreen({super.key});

  @override
  ConsumerState<MasterTemplateScreen> createState() => _MasterTemplateScreenState();
}

class _MasterTemplateScreenState extends ConsumerState<MasterTemplateScreen> {
  bool _isImporting = false;

  Future<void> _importTemplate() async {
    if (_isImporting) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result == null) return;

    setState(() => _isImporting = true);

    try {
      final file = result.files.single;
      final bytes = file.bytes ?? (file.path != null ? File(file.path!).readAsBytesSync() : null);
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membaca file. Coba pilih file lain.')),
          );
        }
        return;
      }

      final excel = excel_lib.Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File Excel kosong atau tidak valid')),
          );
        }
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final templatesDir = Directory('${appDir.path}/templates');
      if (!await templatesDir.exists()) {
        await templatesDir.create(recursive: true);
      }

      final destPath = '${templatesDir.path}/template_sph.xlsx';
      await File(destPath).writeAsBytes(bytes);

      final repo = ref.read(masterTemplateRepositoryProvider);
      await repo.insert(MasterTemplate(
        fileName: file.name,
        filePath: destPath,
        sheetName: excel.tables.keys.first,
      ));

      ref.invalidate(masterTemplateProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template berhasil diimport')),
        );

        final goToMapping = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Atur Posisi Data'),
            content: const Text('Template berhasil diimport. Apakah Anda ingin mengatur posisi data (cell mapping) sekarang?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Nanti'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Atur Sekarang'),
              ),
            ],
          ),
        );

        if (goToMapping == true && mounted) {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const CellMappingScreen(),
          ));
        }
      }
    } catch (e) {
      debugPrint('Import template error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal import template: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _resetTemplate() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Template'),
        content: const Text('Hapus master template? Export akan menggunakan format default.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(masterTemplateRepositoryProvider);
      final active = await repo.getActive();
      if (active?.id != null) {
        await repo.delete(active!.id!);
        ref.invalidate(masterTemplateProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(masterTemplateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Template'),
        actions: [
          if (_isImporting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.file_upload),
              tooltip: 'Import Template',
              onPressed: _importTemplate,
            ),
        ],
      ),
      body: templateAsync.when(
        data: (template) {
          if (template == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Belum ada Master Template', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Import file Excel template SPH perusahaan Anda\nagar hasil export 100% identik',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.darkGray, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _importTemplate,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Import Template Excel'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 14, color: AppTheme.success),
                                SizedBox(width: 4),
                                Text('Template Aktif', style: TextStyle(fontSize: 12, color: AppTheme.success)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(template.fileName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Sheet: ${template.sheetName ?? "Sheet1"}', style: TextStyle(fontSize: 13, color: AppTheme.darkGray)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => const CellMappingScreen(),
                                ));
                                ref.invalidate(masterTemplateProvider);
                              },
                              icon: const Icon(Icons.grid_on, size: 18),
                              label: const Text('Atur Posisi Data'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _resetTemplate,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Reset'),
                            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error),
                          ),
                        ],
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
                      const Text('Informasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _infoRow('File asli', template.fileName),
                      _infoRow('Lokasi', template.filePath),
                      if (template.createdAt != null) _infoRow('Diimport', template.createdAt!.substring(0, 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildExportNote(),
            ],
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(fontSize: 12, color: AppTheme.darkGray)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildExportNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: AppTheme.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pastikan semua posisi data sudah diatur sebelum export.\nTemplate ini akan digunakan untuk semua export Excel.',
              style: TextStyle(fontSize: 11, color: AppTheme.darkGray),
            ),
          ),
        ],
      ),
    );
  }
}
