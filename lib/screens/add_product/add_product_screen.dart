import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/models/product.dart';
import 'package:myinventory/shared/components/default_button.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/toast_message.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class AddProductScreen extends StatefulWidget {
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewcontroller;
  Barcode? barCode;
  bool is_onScan = false;
  bool isflashOn = false;

  final productbarcodeController_text = TextEditingController();
  final productNameController_text = TextEditingController();
  final productPriceController_text = TextEditingController();
  final productTotalPriceController_text = TextEditingController();
  final productQtyController = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    qrViewcontroller?.dispose();
    productbarcodeController_text.dispose();
    productNameController_text.dispose();
    productPriceController_text.dispose();
    productTotalPriceController_text.dispose();
    productQtyController.dispose();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add New Product", style: TextStyle(color: Color(0xFF382959), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF382959)),
      ),
      body: is_onScan ? _buildScannerView() : _buildFormView(context),
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

  Widget _buildFormView(BuildContext context) {
    if (barCode != null) {
      context.read<ProductsController>().getProductbyBarcode(productbarcodeController_text.text).then((value) {
        if (value != null) {
          productNameController_text.text = value.name ?? "";
          productPriceController_text.text = value.price ?? "";
        }
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            _buildField(
              label: "Barcode",
              controller: productbarcodeController_text,
              hint: "Scan or enter barcode",
              icon: Iconsax.scan_barcode,
              suffixIcon: IconButton(
                icon: const Icon(Iconsax.maximize_3, color: Color(0xFF382959)),
                onPressed: () => setState(() => is_onScan = true),
              ),
              validator: (v) => v!.isEmpty ? "Barcode is required" : null,
            ),
            const SizedBox(height: 20),
            _buildField(
              label: "Product Name",
              controller: productNameController_text,
              hint: "Enter product name",
              icon: Iconsax.box,
              validator: (v) => v!.isEmpty ? "Name is required" : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: "Selling Price",
                    controller: productPriceController_text,
                    hint: "0.00",
                    icon: Iconsax.dollar_circle,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Price required" : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    label: "Quantity",
                    controller: productQtyController,
                    hint: "0",
                    icon: Iconsax.archive_1,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Qty required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildField(
              label: "Total Cost Price",
              controller: productTotalPriceController_text,
              hint: "0.00",
              icon: Iconsax.money_3,
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Total cost required" : null,
            ),
            const SizedBox(height: 40),
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
                onPressed: _handleSave,
                child: const Text("Save Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF382959))),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
        ),
      ],
    );
  }

  void _handleSave() async {
    if (_formkey.currentState!.validate()) {
      int? price = int.tryParse(productPriceController_text.text);
      int? qty = int.tryParse(productQtyController.text);
      int? totalprice = int.tryParse(productTotalPriceController_text.text);

      if (price != null && qty != null && totalprice != null) {
        String profit_per_item = ((qty * price - totalprice) / qty).toString();
        context.read<ProductsController>().insertProductByModel(
          model: ProductModel(
            barcode: productbarcodeController_text.text,
            name: productNameController_text.text,
            price: productPriceController_text.text,
            totalprice: productTotalPriceController_text.text,
            qty: productQtyController.text,
            profit_per_item: profit_per_item,
          ),
        ).then((value) {
          showToast(
            message: context.read<ProductsController>().statusInsertBodyMessage.toString(),
            status: context.read<ProductsController>().statusInsertMessage,
          );
          if (context.read<ProductsController>().statusInsertMessage != ToastStatus.Error) {
            Get.back();
          }
        });
      } else {
        showToast(message: "Values must be numbers", status: ToastStatus.Error);
      }
    }
  }

  void onQRViewCreatedCallback(QRViewController controller) {
    setState(() => qrViewcontroller = controller);
    qrViewcontroller?.scannedDataStream.listen((barcode) {
      setState(() {
        barCode = barcode;
        is_onScan = false;
        productbarcodeController_text.text = barcode.code.toString();
      });
      qrViewcontroller?.pauseCamera();
    });
  }
}
