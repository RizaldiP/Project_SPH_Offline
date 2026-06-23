import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../providers/providers.dart';
import 'sph_detail_screen.dart';

class SphListScreen extends ConsumerWidget {
  final String? status;
  const SphListScreen({super.key, this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sphList = ref.watch(sphListProvider(status));

    return Scaffold(
      appBar: AppBar(
        title: Text(status == 'draft' ? 'Draft SPH' : 'SPH'),
      ),
      body: sphList.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Belum ada SPH', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(sphListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final sph = list[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      sph.status == 'draft' ? Icons.edit_note : Icons.check_circle,
                      color: sph.status == 'draft' ? AppTheme.warning : AppTheme.success,
                    ),
                    title: Text(sph.number, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${sph.customerName ?? "-"} • ${sph.date ?? ""}'),
                    trailing: Text(Helpers.formatCurrency(sph.grandTotal)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SphDetailScreen(sphId: sph.id!)),
                    ),
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
