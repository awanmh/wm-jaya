// lib/features/settings/presentation/screens/help_center_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wm_jaya/constants/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  // Data untuk daftar FAQ (Pertanyaan yang Sering Diajukan)
  final List<Map<String, String>> faqs = const [
    {
      'question': 'Bagaimana cara menambahkan produk baru?',
      'answer': 'Untuk menambahkan produk baru, pergi ke halaman "Produk", lalu tekan tombol tambah (+) di pojok kanan atas. Isi semua detail produk yang diperlukan seperti nama, harga, dan kategori, lalu tekan simpan.',
    },
    {
      'question': 'Bagaimana cara melihat laporan penjualan?',
      'answer': 'Anda dapat mengakses semua laporan penjualan melalui menu "Laporan" di navigasi bawah. Di sana, Anda bisa memilih untuk melihat laporan harian, mingguan, atau bulanan.',
    },
    {
      'question': 'Apakah data saya aman?',
      'answer': 'Aplikasi ini menyimpan semua data secara lokal di perangkat Anda. Untuk keamanan tambahan, kami menyarankan untuk melakukan backup data secara berkala melalui menu "Pengaturan" > "Backup Data".',
    },
    {
      'question': 'Bagaimana cara menghapus sebuah kategori?',
      'answer': 'Di halaman "Produk", tekan dan tahan pada kartu kategori yang ingin Anda hapus. Sebuah dialog konfirmasi akan muncul. Perlu diingat, tindakan ini akan menghapus semua produk di dalam kategori tersebut dan tidak dapat diurungkan.',
    },
    {
      'question': 'Bagaimana cara melakukan backup data?',
      'answer': 'Fitur backup data memungkinkan Anda untuk menyimpan salinan database Anda ke lokasi yang aman. Buka menu "Pengaturan" lalu pilih "Backup Data" dan ikuti instruksi yang diberikan.',
    }
  ];

  // Fungsi untuk membuka URL (misalnya untuk email atau telepon)
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Bisa ditambahkan feedback ke user jika gagal
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Pusat Bantuan', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Bagian Header
          Text(
            'Ada yang bisa kami bantu?',
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Temukan jawaban atas pertanyaan Anda di bawah ini.',
            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          // Bagian Pertanyaan yang Sering Diajukan (FAQ)
          Text(
            'Pertanyaan Populer',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => _buildFaqItem(faq['question']!, faq['answer']!)).toList(),
          
          const SizedBox(height: 32),
          
          // Bagian Hubungi Kami
          _buildContactUsCard(),
        ],
      ),
    );
  }

  // Widget untuk setiap item FAQ
  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        iconColor: AppColors.tertiary,
        collapsedIconColor: Colors.grey.shade700,
        title: Text(
          question,
          style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: GoogleFonts.lato(color: Colors.black54, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk kartu "Hubungi Kami"
  Widget _buildContactUsCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.tertiary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tidak menemukan jawaban?',
              style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Hubungi tim dukungan kami untuk mendapatkan bantuan lebih lanjut.',
              style: GoogleFonts.lato(color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _launchURL('mailto:support@wmjaya.com?subject=Bantuan Aplikasi'),
                  icon: const Icon(Icons.email_outlined, color: Colors.white),
                  label: Text('Kirim Email', style: GoogleFonts.lato(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
