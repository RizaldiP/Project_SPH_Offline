import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'template_form_screen.dart';
import '../../services/excel/excel_service.dart';

class TemplateListScreen extends ConsumerWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import dari Excel',
            onPressed: () async {
              await ExcelService.importTemplate(context);
              ref.invalidate(templatesProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplateFormScreen()));
          ref.invalidate(templatesProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: templates.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Belum ada template'),
                  const SizedBox(height: 8),
                  const Text('Import dari Excel atau buat manual', style: TextStyle(color: AppTheme.darkGray)),
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
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(templatesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final template = list[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.lightNavy,
                      child: Text(template.name.isNotEmpty ? template.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(template.name),
                    subtitle: Text(template.description ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateFormScreen(template: template)));
                      ref.invalidate(templatesProvider);
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
    );
  }
}
