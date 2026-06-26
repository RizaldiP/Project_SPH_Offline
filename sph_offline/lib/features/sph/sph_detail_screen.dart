import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../providers/providers.dart';
import '../../services/pdf/pdf_service.dart';
import '../../services/excel/excel_service.dart';
import 'sph_form_screen.dart';

class SphDetailScreen extends ConsumerWidget {
  final int sphId;
  const SphDetailScreen({super.key, required this.sphId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sphAsync = ref.watch(sphDetailProvider(sphId));
    final itemsAsync = ref.watch(sphItemsProvider(sphId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail SPH'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SphFormScreen(sphId: sphId)),
                );
                ref.invalidate(sphDetailProvider(sphId));
                ref.invalidate(sphItemsProvider(sphId));
              } else if (v == 'duplicate') {
                await ref.read(sphRepositoryProvider).duplicate(sphId);
                ref.invalidate(sphListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SPH berhasil diduplikasi')),
                  );
                }
              } else if (v == 'pdf') {
                await PdfService.export(context, sphId);
              } else if (v == 'excel') {
                await ExcelService.export(context, sphId);
              } else if (v == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus SPH'),
                    content: const Text('Yakin ingin menghapus SPH ini?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.white))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(sphRepositoryProvider).delete(sphId);
                  ref.invalidate(sphListProvider);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
              const PopupMenuItem(value: 'duplicate', child: ListTile(leading: Icon(Icons.copy), title: Text('Duplikasi'))),
              const PopupMenuItem(value: 'pdf', child: ListTile(leading: Icon(Icons.picture_as_pdf), title: Text('Export PDF'))),
              const PopupMenuItem(value: 'excel', child: ListTile(leading: Icon(Icons.table_chart), title: Text('Export Excel'))),
              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: AppTheme.error), title: Text('Hapus', style: TextStyle(color: AppTheme.error)))),
            ],
          ),
        ],
      ),
      body: sphAsync.when(
        data: (sph) {
          if (sph == null) return const Center(child: Text('SPH tidak ditemukan'));
          return itemsAsync.when(
            data: (items) => _buildContent(context, ref, sph, items),
            error: (e, _) => Center(child: Text('Error: $e')),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, sph, List items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sph.number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
                  const SizedBox(height: 4),
                  if (sph.title != null && sph.title!.isNotEmpty) Text(sph.title!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Tanggal', value: sph.date ?? '-'),
                  _InfoRow(label: 'Customer', value: sph.customerName ?? '-'),
                  _InfoRow(label: 'Perusahaan', value: sph.customerCompany ?? '-'),
                  _InfoRow(label: 'Alamat', value: sph.customerAddress ?? '-'),
                  _InfoRow(label: 'Kapal', value: sph.shipName ?? '-'),
                  _InfoRow(label: 'Berlaku', value: sph.validityPeriod ?? '-'),
                  if (sph.notes != null && sph.notes!.isNotEmpty) _InfoRow(label: 'Catatan', value: sph.notes!),
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
                  const Text('Item Pekerjaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    const Text('Tidak ada item pekerjaan')
                  else
                    ...items.map((item) => Padding(
                      padding: EdgeInsets.only(left: item.type == 'item' ? 16 : 0, top: 4, bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                item.type == 'section' ? Icons.folder : Icons.article,
                                size: 16,
                                color: item.type == 'section' ? AppTheme.navyBlue : AppTheme.accent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item.label, style: TextStyle(fontWeight: item.type == 'section' ? FontWeight.bold : FontWeight.normal))),
                              if (item.type == 'item')
                                Text(Helpers.formatCurrency(item.totalPrice)),
                            ],
                          ),
                          if (item.type == 'item' && item.qty > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: Text('${item.qty} ${item.unit ?? ""} x ${Helpers.formatCurrency(item.unitPrice)}', style: const TextStyle(color: AppTheme.darkGray, fontSize: 12)),
                            ),
                        ],
                      ),
                    )),
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
                  const Text('Rekap Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _TotalRow(label: 'Total Material', value: Helpers.formatCurrency(sph.totalMaterial)),
                  _TotalRow(label: 'Total Jasa', value: Helpers.formatCurrency(sph.totalJasa)),
                  const Divider(),
                  _TotalRow(label: 'Subtotal', value: Helpers.formatCurrency(sph.subtotal)),
                  _TotalRow(label: 'Diskon', value: '${sph.discount}%'),
                  _TotalRow(label: 'PPN', value: '${sph.ppn}%'),
                  const Divider(),
                  _TotalRow(label: 'Grand Total', value: Helpers.formatCurrency(sph.grandTotal), bold: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label :', style: const TextStyle(color: AppTheme.darkGray))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _TotalRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? AppTheme.navyBlue : null)),
        ],
      ),
    );
  }
}
