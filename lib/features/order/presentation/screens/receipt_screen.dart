// lib/features/order/presentation/screens/receipt_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:wm_jaya/data/models/order.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/constants/app_strings.dart';
import 'package:wm_jaya/features/order/presentation/providers/order_provider.dart';
import 'package:wm_jaya/services/pdf_service.dart';
import 'dart:typed_data';

class ReceiptScreen extends StatelessWidget {
  final int orderId;

  const ReceiptScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.receipt(orderId)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: AppStrings.printReceipt,
            onPressed: () => _printReceipt(context, orderProvider),
          ),
        ],
      ),
      body: FutureBuilder(
        future: orderProvider.getOrderDetails(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = orderProvider.currentOrder;
          if (order == null) return const Center(child: Text(AppStrings.orderNotFound));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(order, dateFormat),
                const SizedBox(height: 24),
                ...order.items.map(_buildReceiptItem),
                const Divider(),
                _buildTotalSection(order.total),
                const SizedBox(height: 24),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Order order, DateFormat dateFormat) {
    return Column(
      children: [
        Text(AppStrings.appName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(AppStrings.receiptSubtitle,
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(dateFormat.format(order.date)),
      ],
    );
  }

  Widget _buildReceiptItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text('${item.quantity}x ${item.product.name}'),
          ),
          Text('Rp ${(item.quantity * item.product.price).toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _buildTotalSection(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppStrings.total, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Rp ${total.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(AppStrings.thankYouNote,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary));
  }

  Future<void> _printReceipt(BuildContext context, OrderProvider provider) async {
    final ctx = context; // Simpan context sebelum async

    try {
      if (provider.currentOrder == null) {
        await provider.getOrderDetails(orderId);
      }

      if (provider.currentOrder != null) {
        final Uint8List pdfData = await PDFService.generateReceipt(provider.currentOrder!);
        await Printing.layoutPdf(onLayout: (format) async => pdfData);
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Gagal mencetak: ${e.toString()}')),
        );
      }
    }
  }
}