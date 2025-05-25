// lib/features/product/presentation/screens/product_add_screen.dart
import 'package:flutter/material.dart';
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
    for (var controller in [_nameController, _stockController, _priceController, _qrController, _newCategoryController]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addProduct)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildCategoryField(),
              if (_isAddingNewCategory) _buildNewCategoryField(),
              const SizedBox(height: 20),
              _buildTextField(_nameController, AppStrings.productNameLabel, Icons.label),
              const SizedBox(height: 20),
              _buildNumericField(_stockController, AppStrings.stockLabel, Icons.inventory),
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
              child: Text('+ Tambah Kategori Baru'),
            ),
          ],
          decoration: const InputDecoration(
            labelText: AppStrings.categoryLabel,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          validator: (value) => value == null ? 'Pilih kategori' : null,
          onChanged: (value) {
            setState(() {
              _isAddingNewCategory = value == 'Tambah Baru';
              _selectedCategory = _isAddingNewCategory ? null : value;
            });
          },
        );
      },
    );
  }

  Widget _buildNewCategoryField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: AppTextField(
        controller: _newCategoryController,
        labelText: 'Nama Kategori Baru',
        prefixIcon: const Icon(Icons.create),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return AppTextField(
      controller: controller,
      labelText: label,
      prefixIcon: Icon(icon),
    );
  }

  Widget _buildNumericField(TextEditingController controller, String label, IconData icon) {
    return AppTextField(
      controller: controller,
      labelText: label,
      prefixIcon: Icon(icon),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildQRField() {
    return AppTextField(
      controller: _qrController,
      labelText: AppStrings.qrCodeLabel,
      prefixIcon: const Icon(Icons.qr_code),
      suffixIcon: IconButton(
        icon: const Icon(Icons.camera_alt, color: AppColors.primary),
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

      if (_isAddingNewCategory && _newCategoryController.text.isNotEmpty) {
        category = _newCategoryController.text.trim();
        await provider.addCategory(category);
      }

      final newProduct = Product(
        id: null,
        category: category,
        name: _nameController.text.trim(),
        stock: int.tryParse(_stockController.text) ?? 0,
        price: double.tryParse(_priceController.text) ?? 0.0,
        qrCode: _qrController.text.trim().isNotEmpty ? _qrController.text.trim() : null,
        createdAt: DateTime.now(),
      );

      await provider.addProduct(newProduct);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && mounted) {
      final qrData = result.toString();
      final parts = qrData.split('|');

      if (parts.length >= 4) {
        bool confirm = await _showConfirmationDialog();
        if (confirm) {
          setState(() {
            _selectedCategory = parts[0]; // Kategori
            _nameController.text = parts[1]; // Nama produk
            _stockController.text = parts[2]; // Stok
            _priceController.text = parts[3]; // Harga
            _qrController.text = qrData;
          });

          // Simpan produk otomatis jika user menyetujui
          await _submitForm();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format QR tidak valid!')),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Konfirmasi"),
            content: const Text("Gunakan data hasil scan untuk menambah produk?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya, Simpan")),
            ],
          ),
        ) ??
        false;
  }
}
