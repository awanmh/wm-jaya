// lib/constants/app_strings.dart
class AppStrings {
  // App Info
  static const String appName = "WM Jaya";
  static const String appTagline = "Kelola Toko";

  // Authentication
  static const String loginTitle = "Selamat Datang";
  static const String usernameHint = "Username";
  static const String passwordHint = "Password";
  static const String loginButton = "MASUK";
  static const String logoutConfirm = "Apakah Anda yakin ingin logout?";
  static const String logoutConfirmTitle = "Konfirmasi Logout";
  static const String logoutConfirmMessage = "Anda akan keluar dari aplikasi.";
  static const String logout = "Keluar";
  static const String cancel = "Batal";

  // Menu Items
  static const String menuProducts = "Produk";
  static const String menuOrders = "Pesanan";
  static const String menuFuel = "Pembelian Bensin";
  static const String menuReports = "Laporan";
  static const String menuSettings = "Pengaturan";
  static const String menuLogout = "Keluar";

  // Product Management
  static const String productTitle = "Manajemen Produk";
  static const String addProduct = "Tambah Produk";
  static const String editProduct = "Edit Produk";
  static const String searchHint = "Cari nama barang...";
  static const String productLoading = "Memuat daftar produk...";
  static const String productLoadError = "Gagal memuat produk.";
  static const String productSaveError = "Gagal menyimpan produk.";
  static const String productUpdateError = "Gagal memperbarui produk.";
  static const String productDeleteError = "Gagal menghapus produk.";
  static const String productNotFound = "Produk tidak ditemukan.";
  static const String categoryAll = "Semua";

  // lib/constants/app_strings.dart
  static const String noQRCode = "Tidak memiliki QR Code";
  static const String deleteConfirmation = "Hapus produk";
  static const String confirmDelete = "Konfirmasi Hapus";

  // Products screen
  static const String addProductTitle = "Tambah Produk";
  static const String categoryLabel = "Kategori";
  static const String productNameLabel = "Nama Produk";
  static const String stockLabel = "Stok";
  static const String priceLabel = "Harga";
  static const String qrCodeLabel = "Kode QR";
  static const String saving = "Menyimpan...";

  // Products Edit
  static const String editProductTitle = "Edit Produk";
  static const String update = "Produk di update";

  // Product categories
  static const addNewCategory = 'Tambah Kategori Baru...';
  static const newCategoryHint = 'Contoh: Elektronik';
  static const categoryExistsError = 'Kategori ini sudah ada';

  // Product List
  static const String productListTitle = "Nama Produk";
  static const String noProductsFound = "Produk Tidak Ditemukan";

  // Order Management
  static const String orderTitle = "Pembuatan Pesanan";
  static const String totalLabel = "Total";
  static const String paymentHint = "Jumlah Pembayaran";

  // Order Creation
  static const String createOrder = "Buat Pesanan";
  static const String searchProducts = "Cari Produk";
  static const String confirmOrder = "Konfirmasi Pesanan";
  static const String cart = "Keranjang";
  static const String checkout = "Checkout";

  static String totalItems(int count) => "Total Item: $count";
  static String totalPriceOrder(double amount) => "Total: Rp ${amount.toStringAsFixed(0)}";
  static String orderTotal(double amount) => "Total Pesanan: Rp ${amount.toStringAsFixed(0)}";

  // Order Details
  static const String orderNotFound = "Pesanan tidak ditemukan";
  static const String orderDate = "Tanggal Pesanan";
  static const String orderStatus = "Status Pesanan";
  static const String total = "Total";
  static String orderDetails(int orderId) => "Detail Pesanan #$orderId";
  static String totalItemsDetail(int count) => "Total Item: $count";

  // Receipt Details
  static String receipt(int orderId) => "Struk Pesanan #$orderId";
  static const String receiptSubtitle = "Struk Pembelian Resmi";
  static const String thankYouNote = "Terima kasih telah berbelanja di WM Jaya";
  static const String printReceipt = "Cetak Struk";

  // Fuel Management
  static const String fuelTitle = "Pembelian Bensin";
  static const String fuelTypeHint = "Jenis Bensin";
  static const String calculateByPrice = "Hitung dari Harga";
  static const String calculateByLiter = "Hitung dari Liter";
  static const String fuelHistoryTitle = "Riwayat Pembelian Bensin";
  static const String fuelTypeLabel = "Jenis Bensin";
  static const String liters = "Liter";
  static const String pricePerLiter = "Harga per Liter";
  static const String totalPrice = "Total Harga";
  static const String noDataAvailable = "Tidak ada data yang ditemukan";
  static const String filterByDate = "Filter Berdasarkan Tanggal";
  static const String fuelSaveSuccess = 'Pembelian bahan bakar berhasil disimpan!';
  static const String invalidFuelValue = 'Nilai harga/liter harus lebih besar dari 0';

  // Report Management
  static const String reportTitle = "Laporan";
  static const String reportDaily = "Laporan Harian";
  static const String reportWeekly = "Laporan Mingguan";
  static const String reportMonthly = "Laporan Bulanan";
  static const String printReport = "Cetak Laporan";

  // Settings Management
  static const String settingsTitle = "Pengaturan";
  static const String backupData = "Backup Data";
  static const String restoreData = "Restore Data";

  // Common Actions
  static const String confirm = "Konfirmasi";
  static const String save = "Simpan";
  static const String delete = "Hapus";
  static const String yes = "Ya";
  static const String no = "Tidak";

  // Error Messages
  static const String errorGeneral = "Terjadi kesalahan";
  static const String errorEmptyField = "Harap isi bidang ini";
  static const String errorInvalidFormat = "Format tidak valid";
  static const String errorUserNotFound = "User tidak ditemukan";
  static const String errorWrongPassword = "Password salah";
}