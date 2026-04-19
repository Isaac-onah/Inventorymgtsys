import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myinventory/models/details_facture.dart';
import 'package:myinventory/models/facture.dart';
import 'package:myinventory/models/viewmodel/best_selling.dart';
import 'package:myinventory/models/viewmodel/earn_spent_vmodel.dart';
import 'package:myinventory/models/viewmodel/low_qty_model.dart';
import 'package:myinventory/models/viewmodel/profitable_vmodel.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfApi {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF382959);
  static const PdfColor accentColor = PdfColor.fromInt(0xFF4CAF50);

  static Future<File> generateReceiptsReport(List<FactureModel> receipts, {String? subtitle}) async {
    final pdf = pw.Document();
    double totalValue = 0;
    for (var r in receipts) {
      totalValue += double.tryParse(r.price ?? '0') ?? 0;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader("Transactions Report", subtitle ?? "Generated on ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}"),
          pw.SizedBox(height: 24),
          _buildReceiptsTable(receipts),
          pw.SizedBox(height: 24),
          _buildTotalSection(totalValue),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    return saveDocument(name: 'Transactions_Report_${DateTime.now().millisecondsSinceEpoch}.pdf', doc: pdf);
  }

  static pw.Widget _buildHeader(String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                pw.SizedBox(height: 4),
                pw.Text(subtitle, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
            ),
            pw.Container(
              height: 50,
              width: 50,
              decoration: const pw.BoxDecoration(color: accentColor, shape: pw.BoxShape.circle),
              child: pw.Center(child: pw.Text("POS", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: accentColor, thickness: 2),
      ],
    );
  }

  static pw.Widget _buildReceiptsTable(List<FactureModel> receipts) {
    final headers = ['Date', 'Receipt ID', 'Items', 'Total'];

    return pw.Table.fromTextArray(
      headers: headers,
      data: receipts.map((r) => [
        r.facturedate ?? '',
        "#1-${r.id}",
        r.itemNames ?? '',
        "N${r.price}",
      ]).toList(),
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: primaryColor),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  static pw.Widget _buildTotalSection(double total) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text("GRAND TOTAL:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          pw.SizedBox(width: 12),
          pw.Text("N${total.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: primaryColor)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 24),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("Inventory Management System", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
          pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
        ],
      ),
    );
  }

  // Helper methods for other reports (legacy but improved)
  static Future<File> generateReport(List<DetailsFactureModel> list, {String? startDate, String? endDate}) async {
    final pdf = pw.Document();
    double total = list.fold(0, (sum, item) => sum + (double.tryParse(item.totalprice ?? '0') ?? 0));

    pdf.addPage(
      pw.MultiPage(
        header: (context) => _buildHeader("Sales Report", "Period: ${startDate ?? 'All'} to ${endDate ?? 'All'}"),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Product', 'Qty', 'Unit Price', 'Total'],
            data: list.map((e) => [e.name, e.qty, "N${e.price}", "N${e.totalprice}"]).toList(),
            headerDecoration: const pw.BoxDecoration(color: primaryColor),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          _buildTotalSection(total),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );
    return saveDocument(name: "Sales_Report_${DateTime.now().millisecondsSinceEpoch}.pdf", doc: pdf);
  }

  static Future<File> generateBestSellingReport(List<BestSellingVmodel> list) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        header: (context) => _buildHeader("Best Selling Report", "Top products by quantity sold"),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Product Name', 'Quantity Sold'],
            data: list.map((e) => [e.name, e.qty]).toList(),
            headerDecoration: const pw.BoxDecoration(color: primaryColor),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          ),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );
    return saveDocument(name: "Best_Selling_Report_${DateTime.now().millisecondsSinceEpoch}.pdf", doc: pdf);
  }

  static Future<File> generateMostProfitableReport(List<ProfitableVModel> list) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        header: (context) => _buildHeader("Profitability Report", "Products ranked by total profit generated"),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Product Name', 'Qty Sold', 'Profit/Unit', 'Total Profit'],
            data: list.map((e) => [e.name, e.qty, "N${e.profit_per_item_on_sale}", "N${e.total_profit}"]).toList(),
            headerDecoration: const pw.BoxDecoration(color: primaryColor),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          ),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );
    return saveDocument(name: "Profitability_Report_${DateTime.now().millisecondsSinceEpoch}.pdf", doc: pdf);
  }

  static Future<File> generateLowQtyReport(List<LowQtyVModel> list) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        header: (context) => _buildHeader("Low Stock Warning", "Products requiring immediate restock"),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Product Name', 'Current Stock Level'],
            data: list.map((e) => [e.name, e.qty]).toList(),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          ),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );
    return saveDocument(name: "Low_Stock_Report_${DateTime.now().millisecondsSinceEpoch}.pdf", doc: pdf);
  }

  static Future<File> generateEarnSpentReport(List<EarnSpentVmodel> list) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        header: (context) => _buildHeader("Expense vs Revenue Analysis", "Detailed comparison by item"),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Product Name', 'Total Spent', 'Total Earned', 'Current Stock'],
            data: list.map((e) => [e.name, "N${e.total_spent}", "N${e.total_earn}", e.rest_qty]).toList(),
            headerDecoration: const pw.BoxDecoration(color: primaryColor),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          ),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );
    return saveDocument(name: "Earn_Spent_Report_${DateTime.now().millisecondsSinceEpoch}.pdf", doc: pdf);
  }

  static Future<File> saveDocument({required String name, required pw.Document doc}) async {
    final bytes = await doc.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    await OpenFile.open(file.path);
  }
}
