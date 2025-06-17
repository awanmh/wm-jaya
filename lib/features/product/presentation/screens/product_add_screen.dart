// lib/features/product/presentation/screens/product_add_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/constants/app_strings.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/features/product/presentation/providers/product_provider.dart';
import 'package:wm_jaya/widgets/common/app_button.dart';
import 'package:wm_jaya/widgets/common/app_textfield.dart';
import 'qr_scanner_screen.dart'; // Import QR Scanner Screen

class ProductAddScreen extends StatefulWidget {
  const ProductAddScreen({super.key});

  @override
  ProductAddScreenState createState() => ProductAddScreenState();
}

class ProductAddScreenState extends State<ProductAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  final _qrController = TextEditingController();
  final _newCategoryController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;
  bool _isAddingNewCategory = false;

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _qrController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.tertiary,
        title: const Text(AppStrings.addProduct),
        titleTextStyle: GoogleFonts.lato(
          color: AppColors.tertiary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCategoryField(),
                  // Tampilkan field kategori baru jika opsi dipilih
                  if (_isAddingNewCategory) _buildNewCategoryField(),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, AppStrings.productNameLabel, Icons.label_outline),
                  const SizedBox(height: 20),
                  _buildNumericField(_stockController, AppStrings.stockLabel, Icons.inventory_2_outlined),
                  const SizedBox(height: 20),
                  _buildNumericField(_priceController, AppStrings.priceLabel, Icons.attach_money),
                  const SizedBox(height: 20),
                  _buildQRField(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    return Consumer<ProductProvider>(
      builder: (_, provider, __) {
        final categories = provider.categories;
        return DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: [
            ...categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )),
            const DropdownMenuItem(
              value: 'Tambah Baru',
              child: Row(
                children: [
                  Icon(Icons.add, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Tambah Kategori Baru'),
                ],
              ),
            ),
          ],
          decoration: const InputDecoration(
            labelText: AppStrings.categoryLabel,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category_outlined),
          ),
          validator: (value) {
            if (!_isAddingNewCategory && value == null) {
              return 'Silakan pilih kategori';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _isAddingNewCategory = value == 'Tambah Baru';
              _selectedCategory = _isAddingNewCategory ? null : value;
              // Kosongkan field kategori baru jika opsi lain dipilih
              if (!_isAddingNewCategory) {
                _newCategoryController.clear();
              }
            });
          },
        );
      },
    );
  }

  Widget _buildNewCategoryField() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: AppTextField(
        controller: _newCategoryController,
        labelText: 'Nama Kategori Baru',
        prefixIcon: const Icon(Icons.create_outlined),
        validator: (value) {
          final provider = context.read<ProductProvider>();
          if (_isAddingNewCategory) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama kategori baru tidak boleh kosong';
            }
            // Cek apakah kategori sudah ada (case-insensitive)
            if (provider.categories.any((cat) => cat.toLowerCase() == value.trim().toLowerCase())) {
              return 'Kategori ini sudah ada';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return AppTextField(
      controller: controller,
      labelText: label,
      prefixIcon: Icon(icon),
      validator: (value) => value == null || value.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }

  Widget _buildNumericField(TextEditingController controller, String label, IconData icon) {
    return AppTextField(
      controller: controller,
      labelText: label,
      prefixIcon: Icon(icon),
      keyboardType: TextInputType.number,
      validator: (value) {
         if (value == null || value.isEmpty) return '$label tidak boleh kosong';
         if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
         return null;
      },
    );
  }

  Widget _buildQRField() {
    return AppTextField(
      controller: _qrController,
      labelText: AppStrings.qrCodeLabel,
      prefixIcon: const Icon(Icons.qr_code_2_outlined),
      suffixIcon: IconButton(
        icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
        onPressed: _scanQRCode,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppButton(
      text: _isLoading ? AppStrings.saving : AppStrings.save,
      onPressed: _isLoading ? null : _submitForm,
      isLoading: _isLoading,
      backgroundColor: AppColors.primary,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final provider = context.read<ProductProvider>();
      String category = _selectedCategory ?? '';

      // Jika pengguna mengetik kategori baru, gunakan itu.
      if (_isAddingNewCategory) {
        category = _newCategoryController.text.trim();
      }

      final newProduct = Product(
        id: null, // id akan di-generate oleh database
        category: category,
        name: _nameController.text.trim(),
        stock: int.tryParse(_stockController.text) ?? 0,
        price: double.tryParse(_priceController.text) ?? 0.0,
        qrCode: _qrController.text.trim().isNotEmpty ? _qrController.text.trim() : null,
        createdAt: DateTime.now(),
      );
      
      // Panggil provider untuk menambahkan produk.
      await provider.addProduct(newProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scanQRCode() async {
    // Navigasi ke QR Scanner Screen
  }

  // Sisa fungsi lain tidak perlu diubah
}
