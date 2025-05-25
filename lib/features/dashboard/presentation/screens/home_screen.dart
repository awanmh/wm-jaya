// /lib/features/dashboard/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/features/auth/presentation/providers/auth_provider.dart';
import 'package:wm_jaya/features/product/presentation/screens/product_screen.dart';
import 'package:wm_jaya/features/order/presentation/screens/order_create_screen.dart';
import 'package:wm_jaya/features/fuel/presentation/screens/fuel_purchase_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_screen.dart';
import 'package:wm_jaya/features/settings/presentation/screens/app_info_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Map<String, dynamic>> menuItems = [
    {'icon': MdiIcons.packageVariant, 'label': 'Produk', 'screen': ProductScreen()},
    {'icon': MdiIcons.gasStation, 'label': 'Bensin', 'screen': FuelPurchaseScreen()},
    {'icon': MdiIcons.bookOpenVariant, 'label': 'Laporan', 'screen': ReportScreen()},
    {'icon': MdiIcons.cog, 'label': 'Pengaturan', 'screen': AppInfoScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildOrderButton(context),
            const SizedBox(height: 20),
            Expanded(child: _buildGrid(context)),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber[600],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Selamat Datang', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Kelola Toko dengan Mudah', style: TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 16),
          Text('WM JAYA', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildOrderButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[600],
          foregroundColor: Colors.blue[900],
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: Colors.black54,
          elevation: 8,
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderCreateScreen())),
        icon: Icon(MdiIcons.cart, color: Colors.blue[900]),
        label: const Text('Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) => _buildMenuItem(context, menuItems[index]),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => item['screen'])),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item['icon'], color: Colors.blue[900], size: 40),
            const SizedBox(height: 10),
            Text(item['label'], textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]))
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: Icon(Icons.exit_to_app, color: Colors.red),
        label: const Text('Keluar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final authProvider = context.read<AuthProvider>();
              try {
                navigator.pop();
                await authProvider.logout();
                if (navigator.mounted) {
                  navigator.pushReplacementNamed('/login');
                }
              } catch (e) {
                if (navigator.mounted) {
                  ScaffoldMessenger.of(navigator.context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
