// lib/features/product/presentation/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/features/product/presentation/providers/product_provider.dart';
import 'package:wm_jaya/widgets/common/app_textfield.dart';

class ProductListScreen extends StatelessWidget {
  final String category;

  const ProductListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer untuk bereaksi terhadap perubahan data
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        // Filter produk berdasarkan kategori yang dipilih
        final filteredProducts =
            provider.products.where((p) => p.category == category).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.tertiary,
            title: Text('Produk - $category'),
            titleTextStyle: GoogleFonts.lato(
              color: AppColors.tertiary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          body: filteredProducts.isEmpty
              ? _buildEmptyState()
              : _buildProductListView(context, filteredProducts),
        );
      },
    );
  }

  Widget _buildProductListView(BuildContext context, List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            product.name.substring(0, 1),
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Stok: ${product.stock} | Harga: ${currencyFormat.format(product.price)}'),
        trailing: _buildPopupMenu(context, product),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, Product product) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      onSelected: (value) {
        if (value == 'edit') {
          _showEditProductDialog(context, product);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, product);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text('Ubah Produk'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus Produk'),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product.name);
    final stockController = TextEditingController(text: product.stock.toString());
    final priceController = TextEditingController(text: product.price.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Produk'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: nameController, labelText: 'Nama Produk'),
                const SizedBox(height: 16),
                AppTextField(controller: stockController, labelText: 'Stok', keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                AppTextField(controller: priceController, labelText: 'Harga', keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedProduct = product.copyWith(
                  name: nameController.text.trim(),
                  stock: int.tryParse(stockController.text) ?? product.stock,
                  price: double.tryParse(priceController.text) ?? product.price,
                );
                // Panggil provider untuk update
                context.read<ProductProvider>().updateProduct(updatedProduct);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Anda yakin ingin menghapus "${product.name}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(product.id!);
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.widgets_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Tidak ada produk",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
           const SizedBox(height: 8),
          Text(
            "Produk dalam kategori ini akan muncul di sini.",
             style: TextStyle(fontSize: 14, color: Colors.grey[600]),
             textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
