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
      backgroundColor: Colors.grey[50],
      appBar: controller.currentIndex == 0
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 80,
              centerTitle: true,
              title: Column(
                children: [
                  Text(
                    controller.appbar_title[controller.currentIndex],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF382959),
                    ),
                  ),
                  Text(
                    controller.sub_appbar_title[controller.currentIndex],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
      body: controller.screens[controller.currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF382959), // Premium green
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            showUnselectedLabels: true,
            onTap: (index) {
              controller.onchangeIndex(index);
            },
            currentIndex: controller.currentIndex,
            items: controller.bottomItems,
          ),
        ),
      ),
    );
  }



  Future<void> deleteDatabase() => databaseFactory.deleteDatabase(databasepath);

}
