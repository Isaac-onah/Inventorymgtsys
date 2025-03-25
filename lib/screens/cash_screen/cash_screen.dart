import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/shared/components/default_button.dart';
import 'package:myinventory/shared/components/default_text_form.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:provider/provider.dart';

class CashScreen extends StatelessWidget {
  double total_amount;
  CashScreen(this.total_amount);

  var text_receivedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    text_receivedController.text = total_amount.toString();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Text("Cash"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: [
          Column(
            children: [
              Text(
                "$total_amount",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Total amount due",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cash Received",
                style: TextStyle(color: Colors.green.shade300),
              ),
              TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: text_receivedController,


                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.white
                ),
                decoration: InputDecoration(
                  fillColor: Color(0xFF24272E),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14, // your height variable
                    horizontal: 12, // your width variable
                  ),
                  filled: true, // your color variable
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(width: 1, color: Color(0xFF387F36)), // your color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(
                      color: Color(0xFF387F36), // your color
                    ),
                  ),
                  labelText: 'Amount', // Pass the label text here
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      text_receivedController.clear();
                    },
                  ),
                  hintText: "Amount...",

                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          defaultButton(
              text: "Cash",
              onpress: () {
                //NOTE close keyboard befor back cz keyboard dispay over previous screen and show an error
                FocusScope.of(context).unfocus();
                String change =
                    (double.parse(text_receivedController.text.toString()) -
                            total_amount)
                        .toString();
                context.read<ProductsController>().addFacture().then((value) {
                  Get.back(
                    result: change,
                  );
                });
              }),
        ]),
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
    required this.onDelete, required this.changeQuatity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C), // dark grey background
        borderRadius: BorderRadius.circular(16), // rounded corners
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                // Unit Price
                Row(
                  children: [
                    Text(
                      "Unit Price: ",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "₦ $unitPrice",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Quantity Text
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 18.0),
                 child: GestureDetector(
                    onTap:changeQuatity,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text( quantity.toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: defaultColor,
                          decorationColor: defaultColor,           // Underline color (different from text)
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  ),
               ),

          // Delete Icon Button
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}