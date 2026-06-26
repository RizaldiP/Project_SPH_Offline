import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/customer.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
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
        title: const Text('Hapus Customer'),
        content: Text('Hapus $count data customer?'),
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
      final repo = ref.read(customerRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.delete(id);
      }
      _clearSelection();
      ref.invalidate(customersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count customer berhasil dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSelecting
            ? Text('${_selectedIds.length} terpilih')
            : const Text('Master Customer'),
        actions: [
          if (_isSelecting) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Pilih Semua',
              onPressed: () {
                setState(() {
                  customers.whenData((list) {
                    _selectedIds.addAll(list.map((c) => c.id!));
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
          ],
        ],
      ),
      floatingActionButton: _isSelecting
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerFormScreen()));
                ref.invalidate(customersProvider);
              },
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari customer...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: customers.when(
              data: (list) {
                final filtered = list.where((c) {
                  if (_search.isEmpty) return true;
                  final q = _search.toLowerCase();
                  return c.name.toLowerCase().contains(q) ||
                      (c.companyName?.toLowerCase().contains(q) ?? false);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(_search.isNotEmpty ? 'Tidak ditemukan' : 'Belum ada customer'),
                        const SizedBox(height: 8),
                        if (_search.isEmpty)
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerFormScreen()));
                              ref.invalidate(customersProvider);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Customer'),
                          ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(customersProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      final isSelected = _selectedIds.contains(customer.id);
                      return Card(
                        color: isSelected ? AppTheme.navyBlue.withValues(alpha: 0.08) : null,
                        child: ListTile(
                          leading: _isSelecting
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleSelection(customer.id!),
                                )
                              : CircleAvatar(
                                  backgroundColor: AppTheme.navyBlue,
                                  child: Text(
                                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                          title: Text(customer.name),
                          subtitle: Text(customer.companyName ?? customer.phone ?? '-'),
                          trailing: _isSelecting ? null : const Icon(Icons.chevron_right),
                          onTap: _isSelecting
                              ? () => _toggleSelection(customer.id!)
                              : () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)),
                                  );
                                  ref.invalidate(customersProvider);
                                },
                          onLongPress: _isSelecting
                              ? null
                              : () {
                                  setState(() {
                                    _isSelecting = true;
                                    _selectedIds.add(customer.id!);
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
