import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../providers/providers.dart';
import 'material_form_screen.dart';

class MaterialListScreen extends ConsumerWidget {
  const MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materials = ref.watch(materialsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Master Material')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialFormScreen()));
          ref.invalidate(materialsProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: materials.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Belum ada material'),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialFormScreen()));
                      ref.invalidate(materialsProvider);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Material'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(materialsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final material = list[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.accent,
                      child: Text(material.name.isNotEmpty ? material.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(material.name),
                    subtitle: Text('${material.category ?? "-"} • ${material.unit ?? ""}'),
                    trailing: Text(Helpers.formatCurrency(material.standardPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => MaterialFormScreen(material: material)));
                      ref.invalidate(materialsProvider);
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
