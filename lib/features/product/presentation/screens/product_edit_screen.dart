// lib/features/product/presentation/screens/product_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/constants/app_strings.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/features/product/presentation/providers/product_provider.dart';
import 'package:wm_jaya/widgets/common/app_button.dart';
import 'package:wm_jaya/widgets/common/app_textfield.dart';

class ProductEditScreen extends StatefulWidget {
  final int productId;

  const ProductEditScreen({super.key, required this.productId});

  @override
  ProductEditScreenState createState() => ProductEditScreenState();
}

class ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  final _qrController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductData();
    });
  }

  Future<void> _loadProductData() async {
    final provider = context.read<ProductProvider>();
    final product = provider.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => Product(id: -1, category: '', name: '', stock: 0, price: 0, createdAt: DateTime.now()),
    );

    if (product.id != -1) {
      _categoryController.text = product.category;
      _nameController.text = product.name;
      _stockController.text = product.stock.toString();
      _priceController.text = product.price.toString();
      _qrController.text = product.qrCode ?? '';
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editProductTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildCategoryField(),
              const SizedBox(height: 20),
              _buildNameField(),
              const SizedBox(height: 20),
              _buildStockField(),
              const SizedBox(height: 20),
              _buildPriceField(),
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
    final categories = context.watch<ProductProvider>().categories;
    return DropdownButtonFormField<String>(
      value: _categoryController.text.isEmpty ? null : _categoryController.text,
      items: categories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      decoration: const InputDecoration(
        labelText: AppStrings.categoryLabel,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Kategori harus dipilih' : null,
      onChanged: (value) => _categoryController.text = value!,
    );
  }

  Widget _buildNameField() {
    return AppTextField(
      controller: _nameController,
      labelText: AppStrings.productNameLabel,
      prefixIcon: const Icon(Icons.label),
      validator: (value) => value == null || value.isEmpty ? 'Nama produk harus diisi' : null,
    );
  }

  Widget _buildStockField() {
    return AppTextField(
      controller: _stockController,
      labelText: AppStrings.stockLabel,
      prefixIcon: const Icon(Icons.inventory),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Stok harus diisi';
        if (int.tryParse(value) == null) return 'Stok harus berupa angka';
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return AppTextField(
      controller: _priceController,
      labelText: AppStrings.priceLabel,
      prefixIcon: const Icon(Icons.attach_money),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Harga harus diisi';
        if (double.tryParse(value) == null) return 'Harga harus berupa angka';
        return null;
      },
    );
  }

  Widget _buildQRField() {
    return AppTextField(
      controller: _qrController,
      labelText: AppStrings.qrCodeLabel,
      prefixIcon: const Icon(Icons.qr_code),
      suffixIcon: IconButton(
        icon: Icon(Icons.camera_alt, color: AppColors.primary),
        onPressed: _scanQRCode,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppButton(
      text: _isLoading ? AppStrings.saving : AppStrings.update,
      onPressed: _submitForm,
      backgroundColor: AppColors.primary,
      isLoading: _isLoading,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: widget.productId,
        category: _categoryController.text,
        name: _nameController.text,
        stock: int.parse(_stockController.text),
        price: double.parse(_priceController.text),
        qrCode: _qrController.text.isNotEmpty ? _qrController.text : null,
        createdAt: DateTime.now(),
      );

      await context.read<ProductProvider>().updateProduct(product);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.pushNamed(context, '/qr-scanner');
    if (result != null && mounted) {
      setState(() => _qrController.text = result.toString());
    }
  }
}
