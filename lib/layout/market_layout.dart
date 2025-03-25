import 'package:flutter/material.dart';
import 'package:myinventory/controllers/layout_controller.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/shared/components/default_text_form.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/styles.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class MarketLayout extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<LayoutController>(context);
    return Scaffold(
      backgroundColor:Colors.black,
      appBar: controller.currentIndex == 0
          ? null
          : AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        flexibleSpace: Container(
          color: Colors.green,
        ),
        title: Center(
          child: Column(
            children: [
              Text(
                controller.appbar_title[controller.currentIndex].toString(),
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              Text(
                controller.sub_appbar_title[controller.currentIndex].toString(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),

      body: controller.screens[controller.currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BottomNavigationBar(
          backgroundColor:Colors.black,
          elevation: 30,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: defaultColor,
          unselectedItemColor: Colors.white,
          onTap: (index) {
            controller.onchangeIndex(index);
          },
          currentIndex: controller.currentIndex,
          items: controller.bottomItems,
        ),
      ),
    );
  }

  _buildSearchField(
    BuildContext context,
    String hint,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: defaultTextFormField(
          //NOTE to open keyboard when pressing on search button
          focus: true,
          onchange: (value) {
            if (value!.length > 1) {
              context.read<ProductsController>().search_In_Products(value);
              //c.search_In_Products(value);
            }
          },
          inputtype: TextInputType.name,
          hinttext: hint,
          border: InputBorder.none,
          cursorColor: Colors.white,
          textColor: Colors.white,
          hintcolor: Colors.white54,
          suffixIcon: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              context.read<ProductsController>().clearSearch();
              context
                  .read<LayoutController>()
                  .onChangeSearchInProductsStatus(false);
            },
          )),
    );
  }


  Future<void> deleteDatabase() => databaseFactory.deleteDatabase(databasepath);

}
