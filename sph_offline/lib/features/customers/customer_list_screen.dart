import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Master Customer')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerFormScreen()));
          ref.invalidate(customersProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: customers.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Belum ada customer'),
                  const SizedBox(height: 8),
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
              padding: const EdgeInsets.all(8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final customer = list[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.navyBlue,
                      child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(customer.name),
                    subtitle: Text(customer.companyName ?? customer.phone ?? '-'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)));
                      ref.invalidate(customersProvider);
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
