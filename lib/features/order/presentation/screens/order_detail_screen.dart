// lib/features/order/presentation/screens/order_detail_screen.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/data/models/order.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/constants/app_strings.dart';
import 'package:wm_jaya/features/order/presentation/providers/order_provider.dart';
import 'package:wm_jaya/widgets/common/app_card.dart';
import 'package:wm_jaya/features/order/presentation/screens/receipt_screen.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/data/repositories/report_repository.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().getOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.orderDetails(widget.orderId)),
        titleTextStyle: const TextStyle(
          color: AppColors.tertiary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.tertiary,
        // Menambahkan tombol hapus di AppBar jika pesanan belum dilaporkan
        actions: [
          if (orderProvider.currentOrder != null && !orderProvider.currentOrder!.reportGenerated)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Batalkan Pesanan',
              onPressed: () => _showCancelConfirmation(context),
            )
        ],
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOrderDetailBody(orderProvider, dateFormat),
    );
  }

  Widget _buildOrderDetailBody(
      OrderProvider orderProvider, DateFormat dateFormat) {
    final order = orderProvider.currentOrder;
    if (order == null) {
      return const Center(child: Text(AppStrings.orderNotFound));
    }

    final formattedDate = dateFormat.format(order.date);
    final status =
        order.reportGenerated ? "Laporan Dibuat" : "Belum Dilaporkan";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(formattedDate, status, order),
          const SizedBox(height: 16),
          Expanded(child: _buildOrderItemsList(order)),
          _buildTotalSection(order.total),
          // Hanya tampilkan tombol jika laporan belum dibuat
          if (!order.reportGenerated) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(String formattedDate, String status, Order order) {
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(AppStrings.orderDate, formattedDate),
          _buildDetailRow(AppStrings.orderStatus, status),
          _buildDetailRow(AppStrings.totalItems(order.items.length), ''),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList(Order order) {
    return ListView.builder(
      itemCount: order.items.length,
      itemBuilder: (ctx, index) => _buildOrderItem(order.items[index]),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(item.quantity.toString(),
              style: TextStyle(color: AppColors.primary)),
        ),
        title: Text(item.product.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Rp ${item.product.price.toStringAsFixed(0)}'),
        trailing: Text('${item.quantity} x',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTotalSection(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppStrings.total, style: const TextStyle(fontSize: 18)),
          Text(
            'Rp ${total.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptScreen(orderId: widget.orderId),
                  ),
                );
              },
              icon: const Icon(Icons.print),
              label: const Text("Cetak Struk"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _completeOrder,
              icon: const Icon(Icons.check),
              label: const Text("Selesai"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.tertiary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // === FUNGSI BARU UNTUK KONFIRMASI & PEMBATALAN ===
  Future<void> _showCancelConfirmation(BuildContext context) async {
    final orderProvider = context.read<OrderProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text('Stok produk akan dikembalikan. Tindakan ini tidak dapat diurungkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // PENTING: Anda perlu membuat fungsi cancelOrder di OrderProvider
        await orderProvider.cancelOrder(widget.orderId);
        
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibatalkan.'),
            backgroundColor: Colors.orange,
          ),
        );
        // Kembali ke layar sebelumnya setelah berhasil
        if (mounted) Navigator.pop(context);

      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Gagal membatalkan pesanan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeOrder() async {
    final orderProvider = context.read<OrderProvider>();
    final reportRepo = context.read<ReportRepository>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final currentOrder = orderProvider.currentOrder;
      if (currentOrder == null) {
        throw Exception('Order tidak ditemukan');
      }

      final itemsData = currentOrder.items.map((item) {
        return {
          'product': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
        };
      }).toList();

      final report = Report(
        type: ReportType.daily,
        total: currentOrder.total,
        date: DateTime.now(),
        period: DateTime.now(),
        createdAt: DateTime.now(),
        data: {
          'sales': {'items': itemsData},
          'fuel': {'items': []} 
        },
      );

      await reportRepo.generateReport(report);

      if (mounted) {
        await orderProvider.markOrderAsReported(widget.orderId);
        await context.read<ReportProvider>().loadReports();
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ReportScreen()),
            (route) => false,
          );
        }

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil disimpan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error completing order: $e\n$stackTrace');

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
