import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:provider/provider.dart';

class CashScreen extends StatefulWidget {
  final double total_amount;
  const CashScreen(this.total_amount, {super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  late TextEditingController text_receivedController;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    text_receivedController = TextEditingController(text: widget.total_amount.toString());
  }

  @override
  void dispose() {
    text_receivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Payment", style: TextStyle(color: Color(0xFF382959), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF382959)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    "Total Amount Due",
                    style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "₦${widget.total_amount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 36, color: Color(0xFF382959)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    "Cash Received",
                    style: TextStyle(color: Color(0xFF382959), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: text_receivedController,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
                  decoration: InputDecoration(
                    fillColor: Colors.grey[100],
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFF382959), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFF382959)),
                    suffixIcon: IconButton(
                      icon: const Icon(Iconsax.close_circle5, color: Colors.grey),
                      onPressed: () => text_receivedController.clear(),
                    ),
                  ),
                ),
              ],
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
                onPressed: isProcessing ? null : () async {
                  FocusScope.of(context).unfocus();
                  setState(() => isProcessing = true);
                  
                  try {
                    double received = double.tryParse(text_receivedController.text) ?? widget.total_amount;
                    String change = (received - widget.total_amount).toString();
                    
                    await context.read<ProductsController>().addFacture();
                    
                    if (mounted) {
                      Get.back(result: change);
                    }
                  } catch (e) {
                    print("Payment error: $e");
                    if (mounted) {
                      setState(() => isProcessing = false);
                    }
                  }
                },
                child: isProcessing 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Confirm Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productName;
  final int unitPrice;
  final int quantity;
  final VoidCallback changeQuatity;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.onDelete,
    required this.changeQuatity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF382959)),
                ),
                const SizedBox(height: 4),
                Text(
                  "₦$unitPrice",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: changeQuatity,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "x$quantity",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF382959)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onDelete,
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.red.withOpacity(0.1),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}