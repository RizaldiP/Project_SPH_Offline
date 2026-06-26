import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/template.dart';
import 'template_form_screen.dart';
import '../../services/excel/excel_service.dart';

class TemplateListScreen extends ConsumerStatefulWidget {
  const TemplateListScreen({super.key});

  @override
  ConsumerState<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends ConsumerState<TemplateListScreen> {
  String _search = '';
  final Set<int> _selectedIds = {};
  bool _isSelecting = false;

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelecting = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelecting = false;
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Template'),
        content: Text('Hapus $count template pekerjaan?'),
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
      final repo = ref.read(templateRepositoryProvider);
      await repo.deleteByIds(_selectedIds.toList());
      _clearSelection();
      ref.invalidate(templatesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count template berhasil dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(templatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSelecting
            ? Text('${_selectedIds.length} terpilih')
            : const Text('Template Pekerjaan'),
        actions: [
          if (_isSelecting) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Pilih Semua',
              onPressed: () {
                setState(() {
                  templates.whenData((list) {
                    _selectedIds.addAll(list.map((t) => t.id!));
                  });
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              tooltip: 'Hapus Terpilih',
              onPressed: _deleteSelected,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Batal',
              onPressed: _clearSelection,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.file_upload),
              tooltip: 'Import dari Excel',
              onPressed: () async {
                await ExcelService.importTemplate(context);
                ref.invalidate(templatesProvider);
              },
            ),
          ],
        ],
      ),
      floatingActionButton: _isSelecting
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplateFormScreen()));
                ref.invalidate(templatesProvider);
              },
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari template pekerjaan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: templates.when(
              data: (list) {
                final filtered = list.where((t) {
                  if (_search.isEmpty) return true;
                  final q = _search.toLowerCase();
                  return t.name.toLowerCase().contains(q) ||
                      (t.description?.toLowerCase().contains(q) ?? false);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(_search.isNotEmpty ? 'Tidak ditemukan' : 'Belum ada template'),
                        const SizedBox(height: 8),
                        Text(
                          _search.isNotEmpty ? 'Coba kata kunci lain' : 'Import dari Excel atau buat manual',
                          style: const TextStyle(color: AppTheme.darkGray),
                        ),
                        if (_search.isEmpty) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await ExcelService.importTemplate(context);
                              ref.invalidate(templatesProvider);
                            },
                            icon: const Icon(Icons.file_upload),
                            label: const Text('Import Excel'),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(templatesProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final template = filtered[index];
                      final isSelected = _selectedIds.contains(template.id);
                      return Card(
                        color: isSelected ? AppTheme.navyBlue.withValues(alpha: 0.08) : null,
                        child: ListTile(
                          leading: _isSelecting
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleSelection(template.id!),
                                )
                              : CircleAvatar(
                                  backgroundColor: AppTheme.lightNavy,
                                  child: Text(
                                    template.name.isNotEmpty ? template.name[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                          title: Text(template.name),
                          subtitle: Text(template.description ?? ''),
                          trailing: _isSelecting ? null : const Icon(Icons.chevron_right),
                          onTap: _isSelecting
                              ? () => _toggleSelection(template.id!)
                              : () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TemplateFormScreen(template: template),
                                    ),
                                  );
                                  ref.invalidate(templatesProvider);
                                },
                          onLongPress: _isSelecting
                              ? null
                              : () {
                                  setState(() {
                                    _isSelecting = true;
                                    _selectedIds.add(template.id!);
                                  });
                                },
                        ),
                      );
                    },
                  ),
                );
              },
              error: (e, _) => Center(child: Text('Error: $e')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
