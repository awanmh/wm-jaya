// lib/features/report/presentation/screens/report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_daily_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_weekly_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_monthly_screen.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  int _currentIndex = 0;
  
  // State untuk setiap jenis laporan
  DateTime _selectedDate = DateTime.now();
  late DateTimeRange _selectedWeek;
  late DateTime _selectedMonth;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Inisialisasi tanggal untuk mingguan dan bulanan
    _selectedWeek = DateFormatter.currentWeek();
    _selectedMonth = DateTime.now();
    
    _rebuildScreens();
    // Muat data untuk tab awal (harian)
    _loadDataForCurrentTab(0);
  }

  // Fungsi untuk membangun ulang daftar layar
  void _rebuildScreens() {
    _screens = [
      // PERBAIKAN: Menambahkan parameter `initialDate` yang wajib diisi
      ReportDailyScreen(initialDate: _selectedDate),
      // Layar mingguan dan bulanan dipanggil sebagai const karena tidak memerlukan parameter awal
      const ReportWeeklyScreen(),
      const ReportMonthlyScreen(),
    ];
  }

  // === Fungsi untuk memuat data berdasarkan tab ===
  void _loadDataForCurrentTab(int index) {
    final provider = context.read<ReportProvider>();
    if (index == 0) { // Daily
      provider.setReportType(ReportType.daily);
      provider.updateDateRange(DateTimeRange(start: _selectedDate, end: _selectedDate.add(const Duration(days: 1))));
    } else if (index == 1) { // Weekly
      provider.setReportType(ReportType.weekly);
      provider.updateDateRange(_selectedWeek);
    } else { // Monthly
      final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
      provider.setReportType(ReportType.monthly);
      provider.updateDateRange(DateTimeRange(start: firstDay, end: lastDay));
    }
  }

  // === Fungsi untuk memilih tanggal/rentang ===
  Future<void> _selectDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now(), locale: const Locale('id', 'ID'));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _rebuildScreens();
        _loadDataForCurrentTab(0);
      });
    }
  }

  Future<void> _selectWeek() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedWeek.start, firstDate: DateTime(2020), lastDate: DateTime.now(), locale: const Locale('id', 'ID'));
    if (picked != null) {
      setState(() {
        _selectedWeek = DateFormatter.getWeekRange(picked);
        _rebuildScreens();
        _loadDataForCurrentTab(1);
      });
    }
  }

  Future<void> _selectMonth() async {
    // Menggunakan DatePicker yang lebih sesuai untuk memilih bulan
    final picked = await showDatePicker(context: context, initialDate: _selectedMonth, firstDate: DateTime(2020), lastDate: DateTime.now(), locale: const Locale('id', 'ID'), initialDatePickerMode: DatePickerMode.year);
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
        _rebuildScreens();
        _loadDataForCurrentTab(2);
      });
    }
  }

  // === Fungsi untuk membangun UI ===
  AppBar _buildAppBar() {
    switch (_currentIndex) {
      case 0: // Daily
        // PERBAIKAN: Mengganti 'rowIndex' menjadi 'yyyy'
        return AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.tertiary, 
          title: Text(DateFormatter.format(_selectedDate, pattern: 'dd MMMM yyyy')),
          titleTextStyle: const TextStyle(
          color: AppColors.tertiary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ), 
          actions: [IconButton(icon: const Icon(Icons.calendar_today), 
          onPressed: _selectDate), _buildRefreshButton()]);
      case 1: // Weekly
        return AppBar(
          backgroundColor: AppColors.primary, 
          foregroundColor: AppColors.tertiary,
          title: Text(DateFormatter.formatWeeklyHeader(_selectedWeek)),
          titleTextStyle: const TextStyle(
          color: AppColors.tertiary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ), 
          actions: [IconButton(icon: const Icon(Icons.calendar_view_week), 
          onPressed: _selectWeek), _buildRefreshButton()]);
      case 2: // Monthly
        // PERBAIKAN: Mengganti 'rowIndex' menjadi 'yyyy'
        return AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.tertiary, 
          title: Text(DateFormatter.format(_selectedMonth, pattern: 'MMMM yyyy')),
          titleTextStyle: const TextStyle(
          color: AppColors.tertiary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ), 
          actions: [IconButton(icon: const Icon(Icons.calendar_today), 
          onPressed: _selectMonth), _buildRefreshButton()]);
      default:
        return AppBar(
          title: const Text("Laporan"), 
          actions: [_buildRefreshButton()]);
    }
  }

  IconButton _buildRefreshButton() {
    return IconButton(icon: const Icon(Icons.refresh), onPressed: () => _loadDataForCurrentTab(_currentIndex), tooltip: 'Muat Ulang Laporan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.primary,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (mounted) {
          setState(() => _currentIndex = index);
          _loadDataForCurrentTab(index);
        }
      },
      selectedItemColor:  AppColors.primary,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Harian'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_view_week), label: 'Mingguan'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bulanan'),
      ],
    );
  }
}
