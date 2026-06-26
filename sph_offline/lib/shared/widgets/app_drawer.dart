import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/customers/customer_list_screen.dart';
import '../../features/materials/material_list_screen.dart';
import '../../features/templates/template_list_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.navyBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.description, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text('SPH Generator', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Offline Mobile', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => _navigate(context, const DashboardScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Master Customer'),
            onTap: () => _navigate(context, const CustomerListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Master Material'),
            onTap: () => _navigate(context, const MaterialListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Template Pekerjaan'),
            onTap: () => _navigate(context, const TemplateListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat SPH'),
            onTap: () => _navigate(context, const HistoryScreen()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            onTap: () => _navigate(context, const SettingsScreen()),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
