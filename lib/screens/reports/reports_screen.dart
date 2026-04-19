import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/screens/reports/report_preview_screen.dart';
import 'package:myinventory/shared/toast_message.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  final List<Map<String, dynamic>> _reportOptions = const [
    {
      "title": "Daily Sales",
      "subtitle": "Overview of sales for a specific date",
      "icon": Iconsax.calendar_1,
      "color": Colors.blue,
      "type": "daily",
    },
    {
      "title": "Range Sales",
      "subtitle": "Sales performance between two dates",
      "icon": Iconsax.calendar_tick,
      "color": Colors.green,
      "type": "range",
    },
    {
      "title": "Best Selling",
      "subtitle": "Top products by sales volume",
      "icon": Iconsax.award,
      "color": Colors.orange,
      "type": "best_selling",
    },
    {
      "title": "Most Profitable",
      "subtitle": "Products generating highest profit",
      "icon": Iconsax.money_send,
      "color": Colors.purple,
      "type": "profitable",
    },
    {
      "title": "Low Stock",
      "subtitle": "Products running low on inventory",
      "icon": Iconsax.status_up,
      "color": Colors.red,
      "type": "low_stock",
    },
    {
      "title": "Item Analysis",
      "subtitle": "Detailed spent vs earned by item",
      "icon": Iconsax.activity,
      "color": Colors.teal,
      "type": "item_analysis",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Reports & Analytics", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Business Reports",
              style: TextStyle(color: Color(0xFF382959), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Select a report type to view and export data",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 25),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: _reportOptions.length,
              itemBuilder: (context, index) {
                final option = _reportOptions[index];
                return _buildReportCard(context, option);
              },
            ),
            const SizedBox(height: 30),
            const Text(
              "Danger Zone",
              style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildActionItem(
              context,
              "Clean Database",
              "Permanently delete all transaction data",
              Iconsax.trash,
              Colors.red,
              () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> option) {
    return InkWell(
      onTap: () => Get.to(() => ReportPreviewScreen(reportType: option['type'], title: option['title'])),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: option['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(option['icon'], color: option['color'], size: 28),
            ),
            const Spacer(),
            Text(
              option['title'],
              style: const TextStyle(color: Color(0xFF382959), fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              option['subtitle'],
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Delete All Data",
      desc: "This action cannot be undone. Are you sure?",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          onPressed: () async {
            await context.read<ProductsController>().cleanDatabase().then((value) {
              showToast(message: "Database Cleared", status: ToastStatus.Success);
              Navigator.pop(context);
            });
          },
          color: Colors.red,
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }
}
