import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class CustomerPickerScreen extends ConsumerWidget {
  const CustomerPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Customer')),
      body: customers.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada customer'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final customer = list[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.navyBlue,
                    child: Text(customer.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(customer.name),
                  subtitle: Text(customer.companyName ?? ''),
                  onTap: () => Navigator.pop(context, customer),
                ),
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
