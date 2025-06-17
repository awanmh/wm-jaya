// lib/features/settings/presentation/screens/terms_conditions_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Syarat & Ketentuan', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
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
              'Syarat & Ketentuan Penggunaan WM Jaya',
              style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Terakhir diperbarui: 18 Juni 2025',
              style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('1. Penerimaan Syarat'),
            _buildParagraph(
              'Dengan mengunduh, menginstal, atau menggunakan aplikasi WM Jaya ("Aplikasi"), Anda setuju untuk terikat oleh Syarat dan Ketentuan ini. Jika Anda tidak menyetujui syarat-syarat ini, jangan gunakan Aplikasi ini.'
            ),

            _buildSectionTitle('2. Lisensi Penggunaan'),
            _buildParagraph(
              'WM Jaya memberikan Anda lisensi terbatas, non-eksklusif, tidak dapat dipindahtangankan, dan dapat dibatalkan untuk menggunakan Aplikasi ini untuk tujuan manajemen toko pribadi atau bisnis Anda pada perangkat yang Anda miliki atau kontroli, sesuai dengan Syarat dan Ketentuan ini.'
            ),

            _buildSectionTitle('3. Tanggung Jawab Pengguna'),
            _buildParagraph(
              'Anda sepenuhnya bertanggung jawab atas semua data yang Anda masukkan dan kelola di dalam Aplikasi, termasuk keakuratan dan keamanannya. Karena Aplikasi ini bersifat offline, semua data disimpan secara lokal di perangkat Anda. Anda bertanggung jawab untuk melakukan backup data secara berkala untuk mencegah kehilangan data akibat kerusakan perangkat, penghapusan aplikasi, atau kejadian tak terduga lainnya.'
            ),

            _buildSectionTitle('4. Batasan Tanggung Jawab'),
            _buildParagraph(
              'Dalam batas maksimal yang diizinkan oleh hukum, pengembang Aplikasi WM Jaya tidak akan bertanggung jawab atas segala kerusakan langsung, tidak langsung, insidental, atau konsekuensial (termasuk namun tidak terbatas pada kehilangan data, keuntungan, atau gangguan bisnis) yang timbul dari penggunaan atau ketidakmampuan untuk menggunakan Aplikasi ini, bahkan jika kami telah diberitahu tentang kemungkinan kerusakan tersebut.'
            ),

            _buildSectionTitle('5. Pembaruan Aplikasi'),
            _buildParagraph(
              'Kami dapat merilis pembaruan untuk Aplikasi dari waktu ke waktu untuk meningkatkan fungsionalitas atau memperbaiki bug. Anda bertanggung jawab untuk menginstal pembaruan terbaru untuk memastikan Aplikasi berjalan dengan optimal.'
            ),
            
            _buildSectionTitle('6. Penghentian'),
            _buildParagraph(
              'Kami dapat menghentikan atau menangguhkan akses Anda ke Aplikasi kapan saja, tanpa pemberitahuan sebelumnya atau tanggung jawab, untuk alasan apa pun, termasuk jika Anda melanggar Syarat dan Ketentuan ini. Anda dapat berhenti menggunakan Aplikasi kapan saja dengan menghapusnya (uninstall) dari perangkat Anda.'
            ),

            _buildSectionTitle('7. Hukum yang Berlaku'),
            _buildParagraph(
              'Syarat dan Ketentuan ini diatur dan ditafsirkan sesuai dengan hukum yang berlaku di Republik Indonesia, tanpa memperhatikan pertentangan ketentuan hukum.'
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
