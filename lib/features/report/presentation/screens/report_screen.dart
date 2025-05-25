// lib/features/report/presentation/screens/report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/features/report/presentation/providers/report_provider.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_daily_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_weekly_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_monthly_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_read_screen.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_detail_screen.dart';
import 'package:wm_jaya/utils/helpers/date_formatter.dart';
import 'package:wm_jaya/widgets/common/app_card.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ReportDailyScreen(),
    const ReportWeeklyScreen(),
    const ReportMonthlyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReportProvider>().loadReports(),
            tooltip: 'Muat Ulang Laporan',
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return _buildLoading();
          if (provider.errorMessage != null) return _buildError(provider);
          return IndexedStack(
            index: _currentIndex,
            children: _screens,
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(ReportProvider provider) {
    return Center(
      child: Text(
        provider.errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.today),
          label: 'Harian',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_view_week),
          label: 'Mingguan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Bulanan',
        ),
      ],
    );
  }
}

class ReportListItem extends StatelessWidget {
  final Report report;

  const ReportListItem({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportReadScreen(report: report),
        ),
      ),
      borderRadius: BorderRadius.circular(12), // Sesuaikan dengan radius AppCard
      child: AppCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    report.type.name.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getDateLabel(report),
                          style: const TextStyle(
                            color: Colors.blueAccent, 
                            fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'detail',
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.info_outline),
                              title: Text('Detail Laporan'),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'detail') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportDetailScreen(report: report),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Total: Rp ${report.total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Dibuat: ${DateFormatter.format(report.createdAt)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateLabel(Report report) {
    switch (report.type) {
      case ReportType.daily:
        return DateFormatter.format(report.period, pattern: 'HH:mm');
      case ReportType.weekly:
        return DateFormatter.format(report.period, pattern: 'dd MMM');
      case ReportType.monthly:
        return DateFormatter.format(report.period, pattern: 'MMMM yyyy');
    }
  }
}