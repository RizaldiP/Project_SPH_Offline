import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../providers/providers.dart';
import '../sph/sph_detail_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final sphList = ref.watch(sphListProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat SPH')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari SPH...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: sphList.when(
              data: (list) {
                final filtered = list.where((sph) {
                  if (_search.isEmpty) return true;
                  return sph.number.toLowerCase().contains(_search.toLowerCase()) ||
                      (sph.customerName?.toLowerCase().contains(_search.toLowerCase()) ?? false);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('Belum ada riwayat SPH'),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(sphListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final sph = filtered[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            sph.status == 'draft' ? Icons.edit_note : Icons.check_circle,
                            color: sph.status == 'draft' ? AppTheme.warning : AppTheme.success,
                          ),
                          title: Text(sph.number, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${sph.customerName ?? "-"} • ${sph.date ?? ""}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(Helpers.formatCurrency(sph.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(sph.status == 'draft' ? 'Draft' : 'Selesai', style: TextStyle(fontSize: 11, color: sph.status == 'draft' ? AppTheme.warning : AppTheme.success)),
                            ],
                          ),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SphDetailScreen(sphId: sph.id!))),
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
