// lib/features/order/presentation/screens/order_create_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/data/models/product.dart';
import 'package:wm_jaya/features/order/presentation/providers/order_provider.dart';
import 'package:wm_jaya/features/order/presentation/screens/order_detail_screen.dart';

class OrderCreateScreen extends StatefulWidget {
  const OrderCreateScreen({super.key});

  @override
  State<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends State<OrderCreateScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.tertiary,
        title: const Text('Buat Order Baru'),
        titleTextStyle: const TextStyle(
          color: AppColors.tertiary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _showCartDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchTextField(orderProvider),
          _buildProductList(orderProvider),
          CheckoutSection(
            totalAmount: orderProvider.totalAmount,
            totalItems: orderProvider.totalItems,
            onCheckout: () => _confirmOrder(context, orderProvider),
            onCancel: () => orderProvider.clearCart(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTextField(OrderProvider orderProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Cari Produk',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              orderProvider.searchProducts('');
            },
          ),
        ),
        onChanged: (value) {
          orderProvider.searchProducts(value);
        },
      ),
    );
  }

  Widget _buildProductList(OrderProvider orderProvider) {
    return Expanded(
      child: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.filteredProducts.isEmpty
              ? const Center(child: Text('Tidak ada produk tersedia'))
              : ListView.builder(
                  itemCount: orderProvider.filteredProducts.length,
                  itemBuilder: (_, index) {
                    final product = orderProvider.filteredProducts[index];
                    return ProductItem(
                      product: product,
                      onAdd: () => orderProvider.addToCart(product),
                      onRemove: () => orderProvider.removeFromCart(product),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmOrder(BuildContext context, OrderProvider provider) async {
    if (provider.cartItems.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong!')),
      );
      return;
    }

    final currentContext = context; // Simpan BuildContext sebelum async
    if (!mounted) return;

    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final int newOrderId = await provider.createOrder();
      if (!mounted) return;

      Navigator.pop(currentContext); // Tutup loading dialog

      if (newOrderId != -1) {
        debugPrint('Navigasi ke OrderDetailScreen dengan ID: $newOrderId');
        Navigator.pushReplacement(
          currentContext,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: newOrderId),
          ),
        );
      } else {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Gagal membuat order.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(currentContext);
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Gagal membuat order: ${e.toString()}')),
      );
    }
  }

  void _showCartDialog(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Keranjang Belanja"),
          content: orderProvider.cartItems.isEmpty
              ? const Text("Keranjang masih kosong.")
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: orderProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = orderProvider.cartItems[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text("Qty: ${item.quantity} - ${currencyFormat.format(item.product.price)}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            orderProvider.removeFromCart(item.product);
                          },
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmOrder(context, orderProvider);
              },
              child: const Text("Checkout"),
            ),
          ],
        );
      },
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductItem({
    required this.product,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return ListTile(
      title: Text(product.name),
      subtitle: Text('Stok: ${product.stock} - Harga: ${currencyFormat.format(product.price)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: product.stock > 0 ? onRemove : null,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: product.stock > 0 ? onAdd : null,
          ),
        ],
      ),
    );
  }
}

class CheckoutSection extends StatelessWidget {
  final double totalAmount;
  final int totalItems;
  final VoidCallback onCheckout;
  final VoidCallback onCancel;

  const CheckoutSection({
    required this.totalAmount,
    required this.totalItems,
    required this.onCheckout,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Total Item: $totalItems | Total Harga: Rp$totalAmount'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Batal')),
              ElevatedButton(onPressed: onCheckout, child: const Text('Checkout')),
            ],
          ),
        ],
      ),
    );
  }
}
