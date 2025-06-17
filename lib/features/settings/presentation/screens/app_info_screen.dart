// lib/features/settings/presentation/screens/app_info_screen.dart
import 'package:flutter/material.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/features/settings/presentation/screens/help_center_screen.dart';
import 'package:wm_jaya/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:wm_jaya/features/settings/presentation/screens/terms_condition_screen.dart';
import 'package:wm_jaya/features/settings/presentation/screens/backup_restore_screen.dart';
class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Info Aplikasi'),
        backgroundColor: AppColors.accentDark,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Kartu konten utama
            Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     // --- PERUBAHAN DI SINI ---
                    // Ganti FlutterLogo dengan gambar Anda
                    Image.asset(
                        'assets/images/icon.png', // Sesuaikan path dengan nama file Anda
                        width: 80, // Atur lebar gambar
                        height: 80, // Atur tinggi gambar
                      ),
                      // -------------------------
                    const SizedBox(height: 16),

                    // Nama Aplikasi
                    const Text(
                      'WM JAYA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Versi Aplikasi
                    const Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pembatas
                    const Divider(),
                    const SizedBox(height: 10),

                    // Item Menu
                    _buildInfoTile(
                      context,
                      icon: Icons.help_outline,
                      title: 'Pusat Bantuan',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                      },
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.description_outlined,
                      title: 'Syarat & Ketentuan',
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen()));
                      },
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Kebijakan Privasi',
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                      },
                    ),
                     _buildInfoTile(
                      context,
                      icon: Icons.swap_horiz_outlined,
                      title: 'Konversi Data',
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupRestoreScreen()));
                      },
                    ),
                     _buildInfoTile(
                      context,
                      icon: Icons.backup_outlined,
                      title: 'Backup Data',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupRestoreScreen()));
                      },
                    ),
                     _buildInfoTile(
                      context,
                      icon: Icons.cleaning_services_outlined,
                      title: 'Bersihkan Cache',
                      onTap: () {
                        _showConfirmationDialog(
                          context,
                          title: 'Bersihkan Cache',
                          content: 'Apakah Anda yakin ingin membersihkan cache? Tindakan ini tidak dapat diurungkan.',
                          onConfirm: () {
                            // TODO: Tambahkan logika untuk membersihkan cache
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cache berhasil dibersihkan!')),
                            );
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.delete_forever_outlined,
                      title: 'Hapus Data',
                      onTap: () {
                         _showConfirmationDialog(
                          context,
                          title: 'Hapus Semua Data',
                          content: 'PERINGATAN: Semua data Anda akan dihapus secara permanen. Apakah Anda yakin ingin melanjutkan?',
                          onConfirm: () {
                            // TODO: Tambahkan logika untuk menghapus data
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Semua data telah dihapus!')),
                            );
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.language_outlined,
                      title: 'English',
                      onTap: () {
                        // TODO: Tambahkan logika untuk mengubah bahasa
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Fungsi ubah bahasa belum tersedia.')),
                         );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40), // Memberi jarak sebelum footer
            
            // Teks Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Made with ',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const Icon(Icons.favorite, color: Colors.red, size: 16),
                Text(
                  ' in Indonesia',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget bantuan untuk membuat ListTile
  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Widget bantuan untuk menampilkan dialog konfirmasi
  void _showConfirmationDialog(BuildContext context, {required String title, required String content, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Konfirmasi'),
              onPressed: onConfirm,
            ),
          ],
        );
      },
    );
  }
}
