import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});
  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String _selectedPeriod = 'Mei 2026';
  final _periods = ['Hari Ini', 'Minggu Ini', 'Mei 2026', 'April 2026'];
  final double _omzet = 47200000, _hpp = 31800000, _laba = 15400000;
  final _dailySales = [
    {'day': 'Sen', 'value': 5200000.0}, {'day': 'Sel', 'value': 7800000.0},
    {'day': 'Rab', 'value': 4500000.0}, {'day': 'Kam', 'value': 9200000.0},
    {'day': 'Jum', 'value': 6100000.0}, {'day': 'Sab', 'value': 8300000.0},
    {'day': 'Min', 'value': 6100000.0},
  ];
  final _topProducts = [
    {'name': 'PVC Motif Kayu-01', 'qty': 162, 'unit': 'lbr'},
    {'name': 'Plafon Gypsum 60×60', 'qty': 340, 'unit': 'm'},
    {'name': 'Wallpanel Marmer-03', 'qty': 98, 'unit': 'lbr'},
  ];

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { ref.read(transactionProvider.notifier).loadTransactions(); ref.read(productProvider.notifier).loadProducts(); }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary, automaticallyImplyLeading: false,
        title: const Text('Laporan Otomatis', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [IconButton(onPressed: () => _exportPdf(context), icon: const Icon(Icons.download_rounded, color: Colors.white))],
      ),
      body: SingleChildScrollView(child: Column(children: [
        Container(
          color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Text('Periode Laporan', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod, isDense: true,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  onChanged: (val) => setState(() => _selectedPeriod = val!),
                  items: _periods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                ),
              ),
            ),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(children: [
            _buildMetric('Omzet', _omzet, AppColors.primary),
            const SizedBox(width: 8),
            _buildMetric('HPP', _hpp, const Color(0xFFE67E22)),
            const SizedBox(width: 8),
            _buildMetric('Laba', _laba, AppColors.success),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Penjualan harian (7 hari terakhir)', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround, maxY: 12000000,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < _dailySales.length) return Padding(padding: const EdgeInsets.only(top: 6), child: Text(_dailySales[idx]['day'] as String, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary)));
                      return const Text('');
                    })),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text(CurrencyFormatter.formatCompact(value).replaceAll('Rp ', ''), style: const TextStyle(fontFamily: 'Poppins', fontSize: 8, color: AppColors.textHint)))),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 3000000, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.divider, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  barGroups: _dailySales.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value['value'] as double, color: AppColors.primary, width: 22, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)))])).toList(),
                )),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Produk terlaris bulan ini', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ..._topProducts.asMap().entries.map((e) {
                final rank = e.key + 1;
                final p = e.value;
                final rankColors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: rankColors[rank - 1].withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: Center(child: Text('$rank', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: rankColors[rank - 1]))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(p['name'] as String, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                    Text('${p['qty']} ${p['unit']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ]),
                );
              }),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => _exportPdf(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.picture_as_pdf_rounded, size: 20), SizedBox(width: 8), Text('Export Laporan PDF Otomatis', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600))]),
            ),
          ),
          const SizedBox(height: 20),
        ])),
      ])),
    );
  }

  Widget _buildMetric(String label, double value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(CurrencyFormatter.formatCompact(value), style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ]),
    ));
  }

  void _exportPdf(BuildContext context) {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(color: AppColors.primary), const SizedBox(height: 16), Text('Menggenerate laporan $_selectedPeriod...', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary))]),
    ));
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Laporan $_selectedPeriod berhasil diexport!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    });
  }
}
