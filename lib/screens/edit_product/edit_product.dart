import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/models/product.dart';
import 'package:myinventory/shared/toast_message.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel model;
  EditProductScreen({required this.model, super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController productbarcodeController_text;
  late TextEditingController productNameController_text;
  late TextEditingController productPriceController_text;
  late TextEditingController productTotalPriceController_text;
  late TextEditingController productQtyController_text;
  late TextEditingController profitperitemcontroller_text;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    productNameController_text = TextEditingController(text: widget.model.name.toString());
    productbarcodeController_text = TextEditingController(text: widget.model.barcode.toString());
    productPriceController_text = TextEditingController(text: widget.model.price.toString());
    productTotalPriceController_text = TextEditingController(text: widget.model.totalprice.toString());
    productQtyController_text = TextEditingController(text: widget.model.qty.toString());
    profitperitemcontroller_text = TextEditingController(text: widget.model.profit_per_item.toString());
  }

  @override
  void dispose() {
    productNameController_text.dispose();
    productbarcodeController_text.dispose();
    productPriceController_text.dispose();
    productTotalPriceController_text.dispose();
    productQtyController_text.dispose();
    profitperitemcontroller_text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var prod_controller = Provider.of<ProductsController>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit ${widget.model.name}", style: const TextStyle(color: Color(0xFF382959), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF382959)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              _buildField(
                label: "Barcode",
                controller: productbarcodeController_text,
                hint: "Barcode",
                icon: Iconsax.scan_barcode,
                enabled: false,
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
                      controller: productQtyController_text,
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
                label: "Profit Per Item (Auto-calculated)",
                controller: profitperitemcontroller_text,
                hint: "0.00",
                icon: Iconsax.status_up,
                enabled: false,
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
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      int? price = int.tryParse(productPriceController_text.text);
                      int? qty = int.tryParse(productQtyController_text.text);
                      // Fallback if totalprice was not populated
                      int totalCost = int.tryParse(productTotalPriceController_text.text) ?? 
                                     (int.tryParse(widget.model.totalprice ?? '0') ?? 0);
                      
                      if (price != null && qty != null) {
                        String profit_per_item = ((qty * price - totalCost) / qty).toString();
                        prod_controller.updateProduct(ProductModel(
                          barcode: widget.model.barcode,
                          name: productNameController_text.text,
                          price: productPriceController_text.text,
                          totalprice: totalCost.toString(),
                          qty: productQtyController_text.text,
                          profit_per_item: profit_per_item
                        )).then((value) {
                          Get.back();
                          showToast(
                            message: prod_controller.statusUpdateBodyMessage,
                            status: prod_controller.statusUpdateMessage
                          );
                        });
                      } else {
                        showToast(message: "Values must be numbers", status: ToastStatus.Error);
                      }
                    }
                  },
                  child: const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
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
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(fontWeight: FontWeight.w600, color: enabled ? Colors.black : Colors.grey[600]),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
            filled: true,
            fillColor: enabled ? Colors.grey[100] : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
