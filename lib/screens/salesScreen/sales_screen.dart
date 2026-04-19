import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/models/product.dart';
import 'package:myinventory/screens/cash_screen/cash_screen.dart';
import 'package:myinventory/screens/change_qty_screen/change_qty.dart';
import 'package:myinventory/shared/components/default_button.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/toast_message.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class SalesScreen extends StatefulWidget {
  @override
  State<SalesScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SalesScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewcontroller;
  Barcode? barCode;
  bool is_onScan = false;
  bool isflashOn = false;
  bool isCashSuccess = false;

  String changeAmount = "";
  String totalPaid = "";
  String receivedCash = "";

  final text_productNameController = TextEditingController();

  @override
  void dispose() {
    qrViewcontroller?.dispose();
    text_productNameController.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await qrViewcontroller?.pauseCamera();
    }
    qrViewcontroller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    var prod_controller = Provider.of<ProductsController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: prod_controller.isloadingGetProducts
          ? const Center(child: CircularProgressIndicator())
          : isCashSuccess 
            ? _buildSuccessView()
            : is_onScan 
              ? _buildScannerView()
              : _buildMainView(prod_controller),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 80, color: Color(0xFF382959)),
          ),
          const SizedBox(height: 24),
          const Text("Completed!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF382959))),
          const SizedBox(height: 8),
          Text("Transaction processed successfully", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _buildSummaryRow("Total Paid", totalPaid, isBold: true),
                const Divider(height: 32),
                _buildSummaryRow("Received", receivedCash),
                const SizedBox(height: 12),
                _buildSummaryRow("Change", changeAmount, color: Colors.redAccent),
              ],
            ),
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF382959),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              onPressed: () => setState(() => isCashSuccess = false),
              child: const Text("New Transaction", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500)),
        Text(
          "₦$value", 
          style: TextStyle(
            color: color ?? const Color(0xFF382959), 
            fontSize: isBold ? 24 : 18, 
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold
          )
        ),
      ],
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: onQRViewCreatedCallback,
          overlay: QrScannerOverlayShape(
            borderColor: const Color(0xFF382959),
            borderWidth: 8,
            borderLength: 30,
            borderRadius: 16,
            cutOutSize: MediaQuery.of(context).size.width * 0.7,
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
                onPressed: () => setState(() => is_onScan = false),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
                onPressed: () {
                  qrViewcontroller?.toggleFlash();
                  setState(() => isflashOn = !isflashOn);
                },
                icon: Icon(isflashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainView(ProductsController prod_controller) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: prod_controller.basket_products.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: prod_controller.basket_products.length,
                  itemBuilder: (context, index) => _basket_item(prod_controller.basket_products[index]),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.shopping_cart, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text("Basket is empty", style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
        ),
        _buildCheckoutSection(prod_controller),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          Expanded(child: _builddropdownSearch()),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => setState(() => is_onScan = true),
            child: Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF382959).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Iconsax.scan_barcode, color: Color(0xFF382959), size: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(ProductsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Price", style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500)),
              Text(
                "₦${controller.totalprice.toStringAsFixed(2)}",
                style: const TextStyle(color: Color(0xFF382959), fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF382959),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              onPressed: controller.basket_products.isEmpty ? null : () => _handleCheckout(controller),
              child: const Text("Continue to Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(ProductsController controller) async {
    double currentTotal = controller.totalprice;
    dynamic res = await Get.to(() => CashScreen(controller.totalprice));
    
    if (res != null) {
      double change = double.tryParse(res.toString()) ?? 0;
      setState(() {
        changeAmount = change.toStringAsFixed(0);
        totalPaid = currentTotal.toStringAsFixed(0);
        receivedCash = (currentTotal + change).toStringAsFixed(0);
        isCashSuccess = true;
      });
    }
  }

  Widget _builddropdownSearch() {
    return TypeAheadField<ProductModel>(
      hideOnError: true,
      controller: text_productNameController,
      builder: (context, controller, focusNode) => TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          fillColor: Colors.grey[100],
          filled: true,
          hintText: 'Search product...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey[400]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
      constraints: const BoxConstraints(maxHeight: 300),
      decorationBuilder: (context, child) => Material(
        type: MaterialType.card,
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: child,
      ),
      itemBuilder: (context, suggestion) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.box, color: Color(0xFF382959), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(suggestion.name.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF382959))),
                    Text('₦${suggestion.price.toString()}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.add_circle_outline, color: Color(0xFF4CAF50), size: 20),
            ],
          ),
        );
      },
      onSelected: (suggestion) async {
        await context.read<ProductsController>().fetchProductBybarCode(suggestion.barcode.toString());
        text_productNameController.clear();
      },
      suggestionsCallback: (pattern) async {
        return await context.read<ProductsController>().autocomplete_Search_forProduct(pattern);
      },
    );
  }

  void onQRViewCreatedCallback(QRViewController controller) {
    setState(() => qrViewcontroller = controller);
    qrViewcontroller?.scannedDataStream.listen((barcode) {
      if (is_onScan) {
        setState(() {
          barCode = barcode;
          is_onScan = false;
        });
        qrViewcontroller?.pauseCamera();
        context.read<ProductsController>().fetchProductBybarCode(barcode.code.toString()).then((value) {
          if (!value) showToast(message: "Item Not found", status: ToastStatus.Error);
        });
      }
    });
  }

  Widget _basket_item(ProductModel model) {
    return ProductCard(
      productName: model.name.toString(),
      unitPrice: int.parse(model.price),
      quantity: int.parse(model.qty),
      onDelete: () {
        context.read<ProductsController>().deleteProductFromBasket(model.barcode.toString());
      },
      changeQuatity: () {
        Get.to(ChangeQtyScreen(
          title: model.name.toString(),
          barcode: model.barcode.toString(),
          qty: model.qty.toString().trim(),
        ));
      },
    );
  }
}
