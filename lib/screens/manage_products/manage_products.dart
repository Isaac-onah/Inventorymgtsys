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
  List<String> headertitles = [
    'Name',
    'BarCode',
    'Price per item',
    'Qty',
    'Edit'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ProductsController>(
        builder: (context, controller, child) {
          print('manageScreen');

          if (controller.isloadingGetProducts) {
            return const Center(child: CircularProgressIndicator());
          }

          final productList = controller.list_ofProduct;

          if (productList.isEmpty) {
            // Empty state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Products Available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          // Product List
          return Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15.0),
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ProductCard(
                    productName: product.name ?? 'No Name',
                    barcode: product.barcode ?? 'No Barcode',
                    stock: int.tryParse(product.qty) ?? 0,
                    isInStock: (int.tryParse(product.qty) ?? 0) > 0,
                    editProcess:(){
                      Get.to(() => EditProductScreen(model: product));
                    },
                    deleteProcess: (){

                      var alertStyle =
                      AlertStyle(animationDuration: Duration(milliseconds: 1));
                      Alert(
                        style: alertStyle,
                        context: context,
                        type: AlertType.error,
                        title: "Delete Item",
                        desc: "Are You Sure You Want To Delete '${product.name}'",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: Colors.blue.shade400,
                          ),
                          DialogButton(
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            onPressed: () {
                              Provider.of<ProductsController>(context, listen: false)
                                  .deleteProduct(product);
                              Get.back();
                            },
                            color: Colors.red.shade400,
                          ),
                        ],
                      ).show();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: defaultColor,
          child: Icon(Icons.add, color: Colors.black,),
          onPressed: () {
            Get.to(AddProductScreen());
          }),
    );
  }

  _build_header_item(String headerTitle) => DataColumn(
      label: Text(headerTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )));

  _build_Row(ProductModel model, BuildContext context) => DataRow(cells: [
        DataCell(Text(model.name.toString())),
        DataCell(Text(model.barcode.toString())),
        DataCell(Text(model.price.toString())),
        DataCell(Text(model.qty.toString())),
        DataCell(Row(
          children: [
            IconButton(
              onPressed: () {
                Get.to(() => EditProductScreen(model: model));
              },
              icon: Icon(
                Icons.edit,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {
                var alertStyle =
                    AlertStyle(animationDuration: Duration(milliseconds: 1));
                Alert(
                  style: alertStyle,
                  context: context,
                  type: AlertType.error,
                  title: "Delete Item",
                  desc: "Are You Sure You Want To Delete '${model.name}'",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.blue.shade400,
                    ),
                    DialogButton(
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () {
                        Provider.of<ProductsController>(context, listen: false)
                            .deleteProduct(model);
                        Get.back();
                      },
                      color: Colors.red.shade400,
                    ),
                  ],
                ).show();
              },
              icon: Icon(
                Icons.delete,
              ),
            ),
          ],
        )),
      ]);

}
// optional: for icons

class ProductCard extends StatelessWidget {
  final String productName;
  final String barcode;
  final int stock;
  final bool isInStock;
  final VoidCallback editProcess;
  final VoidCallback deleteProcess;

  const ProductCard({
    Key? key,
    required this.productName,
    required this.barcode,
    required this.stock,
    this.isInStock = true,
    required this.editProcess,
    required this.deleteProcess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Screen width for spacing, adjust if needed
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // Dark background color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Section (Product Info)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bar Code: $barcode',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // In Stock badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isInStock ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isInStock ? 'In Stock' : 'Out of Stock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Stock: $stock',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Section (Actions)
          Column(
            children: [
              // Edit Button
              GestureDetector(
                onTap: editProcess,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Iconsax.edit, // Edit icon
                    size: 16,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Delete Button
              GestureDetector(
                onTap: deleteProcess,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    LucideIcons.trash2, // Delete icon
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
