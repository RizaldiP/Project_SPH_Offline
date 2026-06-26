import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../shared/widgets/app_drawer.dart';
import '../sph/sph_form_screen.dart';
import '../sph/sph_list_screen.dart';
import '../history/history_screen.dart';
import '../customers/customer_list_screen.dart';
import '../templates/template_list_screen.dart';
import '../materials/material_list_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sphCount = ref.watch(sphListProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('SPH Generator')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selamat Datang', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Buat Surat Penawaran Harga dengan cepat',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SphFormScreen())),
                icon: const Icon(Icons.add),
                label: const Text('Buat SPH Baru', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.edit_note,
                    label: 'Draft SPH',
                    color: AppTheme.warning,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SphListScreen(status: 'draft'))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.check_circle,
                    label: 'Riwayat SPH',
                    color: AppTheme.success,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.people,
                    label: 'Customer',
                    color: AppTheme.navyBlue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.description,
                    label: 'Template',
                    color: AppTheme.lightNavy,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplateListScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.inventory,
                    label: 'Material',
                    color: AppTheme.accent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialListScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.settings,
                    label: 'Pengaturan',
                    color: AppTheme.darkGray,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            sphCount.when(
              data: (list) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Total SPH', value: list.length.toString()),
                  ],
                ),
              ),
              error: (_, _) => const SizedBox(),
              loading: () => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
        Text(label, style: const TextStyle(color: AppTheme.darkGray)),
      ],
    );
  }
}
