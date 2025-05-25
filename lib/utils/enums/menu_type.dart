// lib/utils/enums/menu_type.dart
import 'package:flutter/material.dart';

enum MenuType {
  home(
    Icons.home_outlined,
    'Beranda',
  ),
  products(
    Icons.shopping_bag_outlined,
    'Produk',
  ),
  orders(
    Icons.receipt_outlined,
    'Pesanan',
  ),
  fuel(
    Icons.local_gas_station_outlined,
    'Bensin',
  ),
  reports(
    Icons.analytics_outlined,
    'Laporan',
  ),
  settings(
    Icons.settings_outlined,
    'Pengaturan',
  ),
  logout(
    Icons.logout,
    'Keluar',
  );

  final IconData icon;
  final String label;

  const MenuType(this.icon, this.label);

  String get value => name;

  static MenuType fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => MenuType.home,
    );
  }
}