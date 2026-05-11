import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:myinventory/controllers/facture_controller.dart';
import 'package:myinventory/models/details_facture.dart';
import 'package:myinventory/models/viewmodel/best_selling.dart';
import 'package:myinventory/models/viewmodel/earn_spent_vmodel.dart';
import 'package:myinventory/models/viewmodel/low_qty_model.dart';
import 'package:myinventory/models/viewmodel/profitable_vmodel.dart';
import 'package:myinventory/services/api/pdf_api.dart';
import 'package:provider/provider.dart';

class ReportPreviewScreen extends StatefulWidget {
  final String reportType;
  final String title;

  const ReportPreviewScreen({super.key, required this.reportType, required this.title});

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  int _limit = 15;
  bool _isLoading = false;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final controller = context.read<FactureController>();
    
    try {
      switch (widget.reportType) {
        case 'daily':
          _data = await controller.getReportByDate(DateFormat('yyyy-MM-dd').format(_startDate));
          break;
        case 'range':
          _data = await controller.getDetailsFacturesBetweenTwoDates(
            DateFormat('yyyy-MM-dd').format(_startDate),
            DateFormat('yyyy-MM-dd').format(_endDate),
          );
          break;
        case 'best_selling':
          _data = await controller.getBestSelling(nbOfproduct: _limit.toString());
          break;
        case 'profitable':
          _data = await controller.getMostprofitableList(nbOfproduct: _limit.toString());
          break;
        case 'low_stock':
          _data = await controller.getLowQtyProductInStore(_limit.toString());
          break;
        case 'item_analysis':
          _data = await controller.getEarnSpentGoupeByItem();
          break;
      }
    } catch (e) {
      debugPrint("Error fetching report data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2040),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1B5E20)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (!_isLoading && _data.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF1B5E20)),
              onPressed: _exportToPdf,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
                : _data.isEmpty
                    ? _buildEmptyState()
                    : _buildDataList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    if (widget.reportType == 'item_analysis') return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.reportType == 'daily')
            _buildFilterRow("Target Date", DateFormat('MMM d, yyyy').format(_startDate), () => _selectDate(context, true)),
          if (widget.reportType == 'range') ...[
            _buildFilterRow("Start Date", DateFormat('MMM d, yyyy').format(_startDate), () => _selectDate(context, true)),
            const SizedBox(height: 12),
            _buildFilterRow("End Date", DateFormat('MMM d, yyyy').format(_endDate), () => _selectDate(context, false)),
          ],
          if (['best_selling', 'profitable', 'low_stock'].contains(widget.reportType))
            Row(
              children: [
                const Text("Limit Results:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _limit.toDouble(),
                    min: 5,
                    max: 100,
                    divisions: 19,
                    label: _limit.toString(),
                    activeColor: const Color(0xFF1B5E20),
                    onChanged: (val) {
                      setState(() => _limit = val.toInt());
                    },
                    onChangeEnd: (val) => _fetchData(),
                  ),
                ),
                Text(_limit.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
            Row(
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 16, color: Color(0xFF1B5E20)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No data found for the selected criteria", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final item = _data[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(dynamic item) {
    String title = "";
    String subtitle = "";
    String trailing = "";
    IconData icon = Iconsax.box;
    Color iconColor = const Color(0xFF1B5E20);

    if (item is DetailsFactureModel) {
      title = item.name ?? "Unknown";
      subtitle = "Order Date: ${item.facturedate ?? 'N/A'}";
      trailing = "₦${item.totalprice}";
      icon = Iconsax.receipt_item;
    } else if (item is BestSellingVmodel) {
      title = item.name ?? "Unknown";
      subtitle = "Top Selling Item";
      trailing = "${item.qty} Sold";
      icon = Iconsax.award;
      iconColor = Colors.orange;
    } else if (item is ProfitableVModel) {
      title = item.name ?? "Unknown";
      subtitle = "Profit Analysis";
      trailing = "₦${double.tryParse(item.total_profit.toString())?.toStringAsFixed(2) ?? '0.00'}";
      icon = Iconsax.money_send;
      iconColor = Colors.lightGreen;
    } else if (item is LowQtyVModel) {
      title = item.name ?? "Unknown";
      subtitle = "Critical Stock Level";
      trailing = "${item.qty} left";
      icon = Iconsax.status_up;
      iconColor = Colors.red;
    } else if (item is EarnSpentVmodel) {
      title = item.name ?? "Unknown";
      subtitle = "Earned: ₦${item.total_earn}";
      trailing = "Spent: ₦${item.total_spent}";
      icon = Iconsax.activity;
      iconColor = Colors.teal;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1B5E20),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trailing,
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (item is DetailsFactureModel)
                    Text(
                      "Qty: ${item.qty}",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf() async {
    try {
      final String startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final String endDateStr = DateFormat('yyyy-MM-dd').format(_endDate);
      
      late var file;
      
      switch (widget.reportType) {
        case 'daily':
        case 'range':
          file = await PdfApi.generateReport(_data.cast<DetailsFactureModel>(), startDate: startDateStr, endDate: widget.reportType == 'range' ? endDateStr : null);
          break;
        case 'best_selling':
          file = await PdfApi.generateBestSellingReport(_data.cast<BestSellingVmodel>());
          break;
        case 'profitable':
          file = await PdfApi.generateMostProfitableReport(_data.cast<ProfitableVModel>());
          break;
        case 'low_stock':
          file = await PdfApi.generateLowQtyReport(_data.cast<LowQtyVModel>());
          break;
        case 'item_analysis':
          file = await PdfApi.generateEarnSpentReport(_data.cast<EarnSpentVmodel>());
          break;
      }
      
      await PdfApi.openFile(file);
    } catch (e) {
      debugPrint("PDF Export failed: $e");
    }
  }
}
