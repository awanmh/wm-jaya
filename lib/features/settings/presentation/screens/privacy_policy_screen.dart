// lib/features/settings/presentation/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Kebijakan Privasi', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan Privasi untuk WM Jaya',
              style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Terakhir diperbarui: 18 Juni 2025',
              style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('1. Pengumpulan dan Penggunaan Informasi'),
            _buildParagraph(
              'Aplikasi WM Jaya adalah aplikasi yang berjalan sepenuhnya secara offline. Kami tidak mengumpulkan, menyimpan, atau mengirimkan data pribadi atau data transaksi Anda ke server mana pun. Semua informasi yang Anda masukkan, termasuk data produk, penjualan, dan laporan, disimpan secara lokal di dalam database pada perangkat Anda sendiri.'
            ),

            _buildSectionTitle('2. Penyimpanan Data'),
            _buildParagraph(
              'Seluruh data aplikasi, seperti daftar produk, riwayat transaksi, dan laporan, disimpan dalam database lokal yang aman di dalam penyimpanan internal perangkat Anda. Hanya aplikasi WM Jaya yang dapat mengakses data ini. Data akan tetap ada di perangkat Anda kecuali Anda secara manual menghapusnya melalui fitur "Hapus Data" di dalam aplikasi atau dengan menghapus aplikasi (uninstall).'
            ),

            _buildSectionTitle('3. Keamanan Data'),
            _buildParagraph(
              'Kami berkomitmen untuk melindungi keamanan data Anda. Meskipun data disimpan secara lokal dan tidak ditransmisikan keluar dari perangkat Anda, kami menyarankan Anda untuk menjaga keamanan perangkat Anda sendiri dengan menggunakan kata sandi atau metode penguncian layar lainnya untuk mencegah akses yang tidak sah.'
            ),

            _buildSectionTitle('4. Berbagi Data'),
            _buildParagraph(
              'Karena sifatnya yang offline, aplikasi WM Jaya tidak membagikan data Anda dengan pihak ketiga mana pun. Anda memiliki kendali penuh atas data Anda. Fitur "Backup Data" memungkinkan Anda untuk membuat salinan data Anda, namun proses ini sepenuhnya dikelola oleh Anda dan data tersebut tidak dikirim kepada kami.'
            ),

            _buildSectionTitle('5. Hak Anda'),
            _buildParagraph(
              'Anda memiliki hak penuh untuk mengakses, mengubah, dan menghapus data Anda kapan saja melalui fitur yang tersedia di dalam aplikasi. Menghapus data melalui fitur "Hapus Data" akan menghilangkan semua informasi secara permanen dari perangkat Anda dan tidak dapat dipulihkan.'
            ),

            _buildSectionTitle('6. Perubahan pada Kebijakan Privasi Ini'),
            _buildParagraph(
              'Kami dapat memperbarui Kebijakan Privasi kami dari waktu ke waktu. Kami akan memberitahu Anda tentang perubahan apa pun dengan memposting Kebijakan Privasi yang baru di halaman ini. Anda disarankan untuk meninjau Kebijakan Privasi ini secara berkala untuk setiap perubahan.'
            ),
            
            _buildSectionTitle('7. Hubungi Kami'),
            _buildParagraph(
              'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, Anda dapat menghubungi kami melalui email di support@wmjaya.com.'
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk judul setiap bagian
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Widget helper untuk paragraf
  Widget _buildParagraph(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: GoogleFonts.lato(
        fontSize: 15,
        color: Colors.black54,
        height: 1.6, // Jarak antar baris
      ),
    );
  }
}
