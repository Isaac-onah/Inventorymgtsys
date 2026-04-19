import 'package:flutter/material.dart';
import 'package:myinventory/controllers/facture_controller.dart';
import 'package:myinventory/models/details_facture.dart';
import 'package:myinventory/models/facture.dart';
import 'package:myinventory/services/api/pdf_api.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/styles.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';

class ReceiptsScreen extends StatefulWidget {
  ReceiptsScreen({Key? key}) : super(key: key);

  @override
  _ReceiptsScreenState createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReceipts();
    });
  }

  void _fetchReceipts() {
    String? startDateText;
    String? endDateText;
    if (_selectedDateRange != null) {
      startDateText = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start);
      endDateText = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end);
    }
    context.read<FactureController>().getAllFilteredReceipts(
          startDate: startDateText,
          endDate: endDateText,
          itemName: _searchController.text,
        );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime(2040),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF382959),
            colorScheme: const ColorScheme.light(primary: Color(0xFF382959), surface: Colors.white),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _fetchReceipts();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
    });
    _fetchReceipts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background matching HomeScreen
      appBar: AppBar(
        title: const Text("Receipts", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      floatingActionButton: Consumer<FactureController>(
        builder: (context, controller, child) {
          return FloatingActionButton.extended(
            onPressed: controller.list_of_receipts.isEmpty ? null : () async {
              String subtitle = "All Transactions";
              if (_selectedDateRange != null) {
                subtitle = "Filtered from ${DateFormat('MMM d').format(_selectedDateRange!.start)} to ${DateFormat('MMM d').format(_selectedDateRange!.end)}";
              }
              if (_searchController.text.isNotEmpty) {
                subtitle += " (Search: ${_searchController.text})";
              }
              
              final file = await PdfApi.generateReceiptsReport(
                controller.list_of_receipts,
                subtitle: subtitle
              );
              await PdfApi.openFile(file);
            },
            backgroundColor: const Color(0xFF382959),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: const Text("Export PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          );
        },
      ),
      body: Consumer<FactureController>(
        builder: (context, controller, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search and Filter Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Search item name...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[500]),
                          onPressed: () {
                            _searchController.clear();
                            _fetchReceipts();
                          },
                        ) : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                         setState((){});
                      },
                      onSubmitted: (value) {
                        _fetchReceipts();
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDateRange(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Color(0xFF382959).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.date_range, color: Color(0xFF382959), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedDateRange == null
                                          ? "Filter by Date Range"
                                          : "${DateFormat('MMM d, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_selectedDateRange!.end)}",
                                      style: const TextStyle(color: Color(0xFF382959), fontSize: 14, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_selectedDateRange != null) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _clearDateFilter,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.close, color: Colors.red, size: 20),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.list_of_receipts.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: controller.list_of_receipts.length,
                        itemBuilder: (context, index) {
                          return _build_Row(controller.list_of_receipts[index], context);
                        },
                      )
                    : Center(
                        child: Text(
                          "No Receipts found",
                          style: TextStyle(color: Colors.grey[500], fontSize: 18),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _build_Row(FactureModel model, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.orangeAccent.withOpacity(0.1),
                    child: const Icon(Icons.receipt_long_outlined, color: Colors.orangeAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('#1-${model.id.toString()}', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('${model.facturedate ?? 'N/A'}', style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),

          if (model.itemNames != null && model.itemNames!.isNotEmpty) ...[
            Text(
              "Items",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: model.itemNames!.split(',').where((i) => i.trim().isNotEmpty).map((item) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF382959).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF382959).withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Text(
                        item.trim(),
                        style: const TextStyle(
                          color: Color(0xFF382959),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Amount", style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(
                    '₦${model.price.toString()}',
                    style: const TextStyle(color: Color(0xFF382959), fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF382959).withOpacity(0.1),
                  foregroundColor: const Color(0xFF382959),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () async {
                  await context.read<FactureController>().getReceiptDetails(model.id.toString()).then((value) {
                    var alertStyle = const AlertStyle(
                        animationDuration: Duration(milliseconds: 200),
                        backgroundColor: Colors.white,
                        titleStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold));
                    Alert(
                      style: alertStyle,
                      title: "Items Breakdown",
                      content: Container(
                        height: 250,
                        width: 300,
                        margin: const EdgeInsets.only(top: 16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _buildheaderDialog(),
                              const Divider(color: Colors.grey),
                              ...value.map((e) => _builddetailsfacture_item(e)).toList(),
                              const Divider(color: Colors.grey),
                              const SizedBox(height: 8),
                              _buildResult(model.price.toString()),
                            ],
                          ),
                        ),
                      ),
                      context: context,
                      buttons: [
                        DialogButton(
                          color: const Color(0xFF382959),
                          radius: BorderRadius.circular(16),
                          child: const Text("Close", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ).show();
                  }).catchError((error) {
                    print('error fetching details $error');
                  });
                },
                icon: const Icon(Icons.list_alt, size: 18),
                label: const Text("Details", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _builddetailsfacture_item(DetailsFactureModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              model.name.toString(),
              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              model.qty.toString(),
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '₦${double.parse(model.price.toString()) * double.parse(model.qty.toString())}',
              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildheaderDialog() {
    return Row(
      children: [
        Expanded(flex: 2, child: Text('Item Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]))),
        Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]))),
        Expanded(flex: 1, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]))),
      ],
    );
  }

  Widget _buildResult(String price) {
    return Row(
      children: [
        Expanded(child: Container(), flex: 1),
        Expanded(child: Container(), flex: 1),
        Expanded(
          flex: 1,
          child: Text(
            '₦$price',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Color(0xFF382959), fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ),
      ],
    );
  }
}
