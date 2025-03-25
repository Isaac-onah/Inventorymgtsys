import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:get/get.dart';
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
  Barcode? barCode = null;
  bool is_onScan = false;
  bool isflashOn = true;

//For fields if has data

  var productbarcodeController_text = TextEditingController();
  var productNameController_text = TextEditingController();
  var productPriceController_text = TextEditingController();
  var productTotalPriceController_text = TextEditingController();
  var productQtyController = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    this.qrViewcontroller?.dispose();
    super.dispose();
  }

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace: Container(
        color: Colors.green,
        ),
        title: Text("Add New Product"),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (is_onScan) _buildQr(context),
          if (is_onScan)
            Positioned(
              top: 10,
              child: _buildControlButton(),
            ),
          if (!is_onScan)
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _build_Form(context),
                  SizedBox(
                    height: 35,
                  ),
                  _buildSubmitRow(context),
                  SizedBox(
                    height: 35,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  _buildQr(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreatedCallback,
        overlay: QrScannerOverlayShape(
            borderColor: defaultColor,
            borderWidth: 7,
            borderLength: 20,
            borderRadius: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.7),
      );

  void onQRViewCreatedCallback(QRViewController controller) {
    setState(() {
      this.qrViewcontroller = controller;
    });

    qrViewcontroller?.scannedDataStream.listen((barcode) {
      setState(() {
        this.barCode = barcode;
        FlutterBeep.beep();
        is_onScan = false;
        qrViewcontroller?.pauseCamera();

        productbarcodeController_text.text = barcode.code.toString();
      });
    });
  }

  _build_Form(BuildContext context) {
    if (barCode != null) {
      //NOTE check if product exist
      context
          .read<ProductsController>()
          .getProductbyBarcode(productbarcodeController_text.text.toString())
          .then((value) {
        if (value != null) {
          productNameController_text.text = value.name.toString();
          productPriceController_text.text = value.price.toString();
        }
        // print("is product exist " +
        //     context.read<ProductsController>().isProductExist.toString());
      });
    }

    return Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
          child: Column(
            children: [
              TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "barcode must not be empty";
                    }
                    return null;
                  },
                  // readonly: context.read<ProductsController>().isProductExist
                  //     ? true
                  //     : false,

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

                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            is_onScan = true;
                          });
                        },
                        icon: Icon(Icons.qr_code_scanner,color:Color(0xFF387F36) ,)),
                  ),
                  controller: productbarcodeController_text),
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
                  readOnly: context.read<ProductsController>().isProductExist
                      ? true
                      : false,
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
                   labelText: 'Name', // Pass the label text here
                   labelStyle: TextStyle(
                     color: Colors.white,
                     fontFamily: 'Roboto',
                     fontWeight: FontWeight.w400,
                     fontSize: 16,
                   ),
                   hintText: "Name...",
                 ),
                  controller: productNameController_text),
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
                          labelText: 'Price per item...', // Pass the label text here
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          hintText: "Price per item...",
                        ),
                        controller: productPriceController_text
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Qty must not be empty";
                          }
                          return null;
                        },
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
                          labelText: 'qty...', // Pass the label text here
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          hintText: "qty...",
                        ),
                        keyboardType: TextInputType.phone,
                        controller: productQtyController),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Total Price must not be empty";
                    }
                    return null;
                  },
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
                    labelText: 'Total Price...', // Pass the label text here
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    hintText: "Total Price...",
                  ),
                  keyboardType: TextInputType.phone,
                  controller: productTotalPriceController_text),
            ],
          ),
        ));
  }

  _buildSubmitRow(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: defaultButton(
              //width: MediaQuery.of(context).size.width * 0.4,
              text: "Save",
              onpress: () async {
                if (_formkey.currentState!.validate()) {
                  int? price = int.tryParse(productPriceController_text.text);
                  int? qty = int.tryParse(productQtyController.text);
                  int? totalprice =
                      int.tryParse(productTotalPriceController_text.text);
                  if (price != null && qty != null && totalprice != null) {
                    print("valid");
                    String profit_per_item =
                        ((qty * price - totalprice) / qty).toString();
                    context
                        .read<ProductsController>()
                        .insertProductByModel(
                            model: ProductModel(
                                barcode: productbarcodeController_text.text,
                                name: productNameController_text.text,
                                price: productPriceController_text.text,
                                totalprice:
                                    productTotalPriceController_text.text,
                                qty: productQtyController.text,
                                profit_per_item: profit_per_item))
                        .then((value) {
                      if (context
                              .read<ProductsController>()
                              .statusInsertMessage ==
                          ToastStatus.Error) {
                        showToast(
                            message: context
                                .read<ProductsController>()
                                .statusInsertBodyMessage
                                .toString(),
                            status: context
                                .read<ProductsController>()
                                .statusInsertMessage);
                      } else {
                        productbarcodeController_text.clear();
                        productNameController_text.clear();
                        productPriceController_text.clear();
                        productQtyController.clear();
                        // marketController_needed.onchangeIndex(0);

                        Get.back();
                        showToast(
                            message: context
                                .read<ProductsController>()
                                .statusInsertBodyMessage
                                .toString(),
                            status: context
                                .read<ProductsController>()
                                .statusInsertMessage);
                      }
                    });
                  } else {
                    showToast(
                        message: "Price, Total Price Or Qty Must be a number ",
                        status: ToastStatus.Error);
                  }
                } else {
                  print("invalid");
                }
              }),
        ),
      ],
    );
  }

  _buildControlButton() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //  qrViewcontroller!.getFlashStatus() == true
          IconButton(
              onPressed: () {
                qrViewcontroller!.getFlashStatus().then((value) {
                  setState(() {
                    isflashOn = value!;
                  });
                });
                qrViewcontroller!.toggleFlash();
              },
              icon: Icon(
                isflashOn ? Icons.flash_on : Icons.flash_off,
                color: defaultColor,
                size: 35,
              )),
          IconButton(
              onPressed: () async {
                await qrViewcontroller?.pauseCamera();
                setState(() {
                  is_onScan = false;
                });
              },
              icon: Icon(
                Icons.close,
                color: defaultColor,
                size: 35,
              ))
          // : IconButton(
          //     onPressed: () {
          //       qrViewcontroller!.toggleFlash();
          //     },
          //     icon: Icon(
          //       Icons.flash_on,
          //       color: defaultColor,
          //     ))
        ],
      );
}
