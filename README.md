# WM Jaya - Aplikasi Manajemen Toko

WM Jaya adalah aplikasi manajemen toko sederhana yang dibangun menggunakan Flutter, dirancang untuk menangani operasi CRUD (Create, Read, Update, Delete) dasar untuk bisnis ritel kecil. Aplikasi ini menyediakan fitur untuk mengelola produk, pesanan, pembelian bahan bakar, laporan, dan pengaturan, dengan fokus pada fungsi offline menggunakan SQLite untuk penyimpanan lokal. Aplikasi ini juga dilengkapi fitur tambahan seperti pemindaian kode QR, pembuatan PDF, dan integrasi Google Drive untuk cadangan data.

## Fitur

- **Otentikasi**: Fitur login pengguna dan pengaturan ulang kata sandi dengan dukungan otentikasi lokal.
- **Dasbor**: Layar utama terpusat untuk akses cepat ke fitur aplikasi.
- **Manajemen Produk**: Tambah, edit, dan lihat produk, termasuk manajemen kategori dan pemindaian/pembuatan kode QR.
- **Manajemen Pesanan**: Buat, lihat, dan kelola pesanan dengan pembuatan kwitansi.
- **Manajemen Bahan Bakar**: Lacak pembelian dan riwayat bahan bakar untuk kebutuhan operasional.
- **Laporan**: Hasilkan laporan harian, mingguan, dan bulanan dengan grafik dan tabel untuk penjualan dan penggunaan bahan bakar.
- **Pengaturan**: Kelola pengaturan aplikasi, termasuk cadangan/pemulihan ke Google Drive dan informasi aplikasi.
- **Dukungan Offline**: Menggunakan SQLite untuk penyimpanan data lokal, memungkinkan fungsi penuh tanpa koneksi internet.
- **Keamanan**: Penyimpanan aman untuk data sensitif dan otentikasi lokal untuk keamanan tambahan.
- **Pembuatan PDF**: Buat dan cetak kwitansi atau laporan dalam format PDF.
- **UI Responsif**: Dioptimalkan untuk Android dan iOS dengan pengalaman pengguna yang konsisten.

## Prasyarat

- **Flutter SDK**: Versi >=3.2.4 dan <4.0.0
- **Dart SDK**: Kompatibel dengan Flutter versi >=3.16.0
- **Lingkungan Pengembangan**: Android Studio, VS Code, atau IDE lain yang mendukung Flutter
- **Akun Google**: Diperlukan untuk fungsi cadangan/pemulihan Google Drive
- **Dependensi**: Tercantum di `pubspec.yaml` (lihat bagian Dependensi)

## Instalasi

1. **Kloning Repositori**:
   ```bash
   git clone <url-repositori>
   cd wm_jaya
   ```

2. **Instal Dependensi**:
   Jalankan perintah berikut untuk mengambil semua paket yang diperlukan:
   ```bash
   flutter pub get
   ```

3. **Hasilkan Kode Injeksi Dependensi**:
   Gunakan `build_runner` untuk menghasilkan kode untuk `injectable`:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Jalankan Aplikasi**:
   Hubungkan perangkat atau emulator dan jalankan:
   ```bash
   flutter run
   ```

5. **Bangun untuk Rilis**:
   Untuk membuat build rilis untuk Android atau iOS:
   ```bash
   flutter build apk  # Untuk Android
   flutter build ios  # Untuk iOS
   ```

## Dependensi

Aplikasi ini bergantung pada paket-paket berikut:

- **flutter**: Kerangka utama untuk membangun antarmuka pengguna.
- **sqflite**: Database SQLite lokal untuk penyimpanan offline.
- **provider**: Manajemen status untuk pembaruan UI reaktif.
- **syncfusion_flutter_charts** dan **fl_chart**: Pustaka untuk visualisasi laporan.
- **pdf** dan **printing**: Untuk pembuatan dan pencetakan PDF.
- **google_sign_in**, **googleapis**, **googleapis_auth**: Integrasi Google Drive untuk cadangan.
- **qr_flutter** dan **qr_code_scanner_plus**: Pembuatan dan pemindaian kode QR.
- **flutter_secure_storage**: Penyimpanan aman untuk data sensitif.
- **local_auth**: Otentikasi berbasis perangkat (misalnya, biometrik).
- **get_it** dan **injectable**: Injeksi dependensi untuk arsitektur yang skalabel.
- **flutter_form_builder**: Pembuatan formulir dinamis untuk input pengguna.
- **intl**: Format untuk tanggal dan mata uang.
- **connectivity_plus**: Pemantauan status jaringan.
- **logger**: Utilitas untuk debugging dan pencatatan.

Untuk daftar lengkap, lihat file `pubspec.yaml`.

## Struktur Proyek

Proyek ini mengikuti pola arsitektur bersih dengan struktur modular:

```
wm_jaya/
├── lib/
│   ├── app/                      # Titik masuk aplikasi dan perutean
│   ├── constants/                # Konstanta aplikasi (warna, string, aset)
│   ├── data/                    # Lapisan data (model, repositori, database lokal)
│   │   ├── local_db/            # Operasi database SQLite dan migrasi
│   │   ├── models/              # Model data (misalnya, Produk, Pesanan, Pengguna)
│   │   ├── repositories/        # Logika akses data
│   ├── di/                      # Pengaturan injeksi dependensi
│   ├── features/                # Modul fitur (otentikasi, dasbor, bahan bakar, dll.)
│   │   ├── auth/                # Otentikasi (login, pengaturan ulang kata sandi)
│   │   ├── dashboard/           # Layar utama dan widget
│   │   ├── fuel/                # Manajemen pembelian dan riwayat bahan bakar
│   │   ├── order/               # Pembuatan dan manajemen pesanan
│   │   ├── product/             # Manajemen produk dan kategori
│   │   ├── report/              # Pelaporan (harian, mingguan, bulanan)
│   │   ├── settings/            # Pengaturan aplikasi dan cadangan/pemulihan
│   ├── locator/                 # Pengaturan GetIt untuk injeksi dependensi
│   ├── providers/               # Penyedia manajemen status
│   ├── services/                # Layanan eksternal (Google Drive, PDF, QR)
│   ├── test/                    # Tes unit dan integrasi
│   ├── utils/                   # Utilitas (dialog, enum, formatter, tema)
│   ├── widgets/                 # Komponen UI yang dapat digunakan kembali (grafik, tombol, dll.)
│   └── main.dart                # Titik masuk aplikasi
├── assets/                      # Aset statis (ikon, font)
└── pubspec.yaml                 # Konfigurasi proyek dan dependensi
```

## Penggunaan

1. **Otentikasi**: Masuk menggunakan kredensial atau Google Sign-In. Gunakan fitur pengaturan ulang kata sandi jika diperlukan.
2. **Dasbor**: Akses fitur utama seperti manajemen produk, pesanan, dan laporan dari layar utama.
3. **Manajemen Produk**: Tambah atau edit produk, pindai kode QR, atau kelola kategori.
4. **Manajemen Pesanan**: Buat pesanan baru, lihat detail, dan hasilkan kwitansi.
5. **Pelacakan Bahan Bakar**: Catat pembelian bahan bakar dan lihat riwayat.
6. **Laporan**: Hasilkan dan lihat laporan penjualan atau penggunaan bahan bakar dengan rentang waktu yang dapat disesuaikan.
7. **Pengaturan**: Konfigurasikan preferensi aplikasi, cadangkan data ke Google Drive, atau pulihkan dari cadangan.

## Pengujian

Jalankan tes unit dan integrasi menggunakan:
```bash
flutter test
```

Tes terletak di direktori `lib/test/`, dengan contoh file tes untuk `auth_provider`.

## Kontribusi

1. Fork repositori.
2. Buat cabang fitur (`git checkout -b fitur/fitur-baru`).
3. Commit perubahan (`git commit -m 'Tambah fitur baru'`).
4. Push ke cabang (`git push origin fitur/fitur-baru`).
5. Buat pull request.

## Lisensi

Proyek ini dilisensikan di bawah Lisensi MIT.

## Kontak

Untuk dukungan atau pertanyaan, hubungi tim pengembangan di <setiawanmuhammad3@gmail.com>.
