import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/models/product.dart';
import 'package:myinventory/shared/components/default_button.dart';
import 'package:myinventory/shared/components/default_text_form.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/toast_message.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatelessWidget {
  ProductModel model;
  EditProductScreen({required this.model});

  var productbarcodeController_text = TextEditingController();
  var productNameController_text = TextEditingController();
  var productPriceController_text = TextEditingController();
  var productTotalPriceController_text = TextEditingController();
  var productQtyController_text = TextEditingController();
  var profitperitemcontroller_text = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    productNameController_text.text = model.name.toString();
    productbarcodeController_text.text = model.barcode.toString();
    productPriceController_text.text = model.price.toString();
    productQtyController_text.text = model.qty.toString();
    profitperitemcontroller_text.text = model.profit_per_item.toString();
    var prod_controller = Provider.of<ProductsController>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: defaultColor,
        title: Text("${model.name}"),
        actions: [
        ],
      ),
      body: _build_Form(),
      bottomNavigationBar:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 30),
        child: defaultButton(
          onpress: () {
              if (_formkey.currentState!.validate()) {
                int? price = int.tryParse(productPriceController_text.text);
                int? qty = int.tryParse(productQtyController_text.text);
                int? totalprice =
                int.tryParse(productQtyController_text.text);
                if (price != null && qty != null && totalprice != null) {
                  print('QTY : ' + productQtyController_text.text.toString());
                  String profit_per_item =
                  ((qty * price - totalprice) / qty).toString();
                  prod_controller
                      .updateProduct(ProductModel(
                      barcode: model.barcode,
                      name: productNameController_text.text,
                      price: productPriceController_text.text,
                      totalprice: productTotalPriceController_text.text,
                      qty: productQtyController_text.text,
                      profit_per_item: profit_per_item))
                      .then((value) {
                    Get.back();
                    showToast(
                        message: prod_controller.statusUpdateBodyMessage,
                        status: prod_controller.statusUpdateMessage);
                  });
                } else {
                  showToast(
                      message: "Price,Total Price Or Qty Must be a number ",
                      status: ToastStatus.Error);
                }
              }
            },
            text:"Save",
            ),
      ),
    );
  }

  _build_Form() => SingleChildScrollView(
        child: Form(
            key: _formkey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    controller: productbarcodeController_text,
                    enabled: false,
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
                      labelText: 'Barcode', // Pass the label text here
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      hintText: "Barcode...",
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Name must not be empty";
                        }
                        return null;
                      },
                      controller: productNameController_text,
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
              labelText: 'Name...', // Pass the label text here
              labelStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              hintText: "Name...",

            ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                 Row(
                   children: [
                     Expanded(
                       child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Price must not be empty";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.phone,
                            controller: productPriceController_text,
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
                           labelText: 'Price...', // Pass the label text here
                           labelStyle: TextStyle(
                             color: Colors.white,
                             fontFamily: 'Roboto',
                             fontWeight: FontWeight.w400,
                             fontSize: 16,
                           ),
                           hintText: "Price",

                         ),),
                     ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Qty must not be empty";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.phone,
                            controller: productQtyController_text,
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
                            labelText: 'Qty', // Pass the label text here
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            hintText: "Qty...",

                          ),
                        ),
                      ),
                   ],
                 ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                      readOnly: true,
                      keyboardType: TextInputType.phone,
                      controller: profitperitemcontroller_text,
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
                      labelText: 'current profit per item...', // Pass the label text here
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      hintText: "current profit per item",

                    ),

                  ),
                ],
              ),
            )),
      );
}
