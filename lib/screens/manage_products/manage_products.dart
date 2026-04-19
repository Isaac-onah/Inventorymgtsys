import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/models/product.dart';
import 'package:myinventory/screens/add_product/add_product_screen.dart';
import 'package:myinventory/screens/edit_product/edit_product.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<ProductsController>(
        builder: (context, controller, child) {
          if (controller.isloadingGetProducts) {
            return const Center(child: CircularProgressIndicator());
          }

          final productList = controller.list_ofProduct;

          if (productList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.box,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products in stock',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final product = productList[index];
              return ProductCard(
                productName: product.name ?? 'No Name',
                barcode: product.barcode ?? 'No Barcode',
                stock: int.tryParse(product.qty) ?? 0,
                price: product.price ?? '0',
                isInStock: (int.tryParse(product.qty) ?? 0) > 0,
                editProcess: () {
                  Get.to(() => EditProductScreen(model: product));
                },
                deleteProcess: () {
                  var alertStyle = const AlertStyle(
                    animationDuration: Duration(milliseconds: 200),
                    titleStyle: TextStyle(fontWeight: FontWeight.bold),
                  );
                  Alert(
                    style: alertStyle,
                    context: context,
                    type: AlertType.warning,
                    title: "Delete Item",
                    desc: "Are you sure you want to delete '${product.name}'?",
                    buttons: [
                      DialogButton(
                        child: const Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16)),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey[400],
                      ),
                      DialogButton(
                        child: const Text("Delete", style: TextStyle(color: Colors.white, fontSize: 16)),
                        onPressed: () {
                          Provider.of<ProductsController>(context, listen: false).deleteProduct(product);
                          Navigator.pop(context);
                        },
                        color: Colors.redAccent,
                      ),
                    ],
                  ).show();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: const Color(0xFF382959),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          Get.to(AddProductScreen());
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productName;
  final String barcode;
  final int stock;
  final String price;
  final bool isInStock;
  final VoidCallback editProcess;
  final VoidCallback deleteProcess;

  const ProductCard({
    Key? key,
    required this.productName,
    required this.barcode,
    required this.stock,
    required this.price,
    this.isInStock = true,
    required this.editProcess,
    required this.deleteProcess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    color: Color(0xFF382959),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'BC: $barcode',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isInStock ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isInStock ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          color: isInStock ? const Color(0xFF382959) : Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Qty: $stock',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₦$price',
                style: const TextStyle(
                  color: Color(0xFF382959),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: editProcess,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Iconsax.edit, size: 16, color: Colors.blue),
                    ),
                  ),
                  IconButton(
                    onPressed: deleteProcess,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
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
}
