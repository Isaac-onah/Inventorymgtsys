import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myinventory/controllers/auth_controller.dart';
import 'package:myinventory/controllers/facture_controller.dart';
import 'package:myinventory/models/details_facture.dart';
import 'package:myinventory/screens/home/total_wallet_balance.dart';
import 'package:myinventory/screens/receipts_screen/receipts_screen.dart';
import 'package:myinventory/services/api/pdf_api.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/toast_message.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  _WalletHomeScreenState createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen> {
  var datecontroller = TextEditingController();
  var startdatecontroller = TextEditingController();
  var enddatecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 180;
    final double spacing = 12;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [
            Consumer<AuthController>(builder: (context, controller, child) {
              return _myDrawer(controller, context);
            }),
            const SizedBox(height: 25),
            TotalWalletBalance(
              context: context,
              totalBalance: '\$39.584',
              crypto: "7.251332 BTC",
              percentage: 3.55,
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('POS Services', style: TextStyle(color: Colors.black38)),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  // Disable GridView's scrolling
                  shrinkWrap: true,
                  // Allow GridView to fit inside SingleChildScrollView
                  crossAxisCount: 2,
                  // Number of columns in the grid
                  crossAxisSpacing: 10.0,
                  // Spacing between columns
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.85,
                  // Spacing between rows
                  children: [
                    recentTransaction(
                      ontap: () {
                        showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.parse('2022-01-01'),
                                lastDate: DateTime.parse('2040-01-01'))
                            .then((value) {
                          //Todo: handle date to string
                          //print(DateFormat.yMMMd().format(value!));
                          var tdate = value != null
                              ? value.toString().split(' ')
                              : null;

                          if (tdate == null) {
                            showToast(
                                message: "date must be not empty or null ",
                                status: ToastStatus.Error);
                            //  print(datecontroller.text);
                          } else {
                            Get.to(() => ReceiptsScreen(tdate[0].toString()));
                          }
                          //datecontroller.text = tdate[0];
                        });
                      },
                      icondata: Iconsax.receipt,
                      myCrypto: 'Receipts',
                      count: '260',
                      label: 'Stock',
                      icon: LucideIcons.box,
                      backgroundColor: const Color(0xFF2C2C2E),
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(80),
                      ),
                      height: cardHeight,
                    ),
                    recentTransaction(
                      ontap: () {
                        datecontroller.clear();
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.parse('2022-01-01'),
                          lastDate: DateTime.parse('2040-01-01'),
                        ).then((value) async {
                          if (value != null) {
                            var selectedDate = value.toString().split(' ')[0];
                            try {
                              await context
                                  .read<FactureController>()
                                  .getReportByDate(selectedDate)
                                  .then((value) {
                                // print(value.length.toString());
                                _openReportByDateOrBetween(value, selectedDate);
                              });
                            } catch (e) {
                              showToast(
                                message: "Error getting report: $e",
                                status: ToastStatus.Error,
                              );
                            }
                          } else {
                            showToast(
                              message: "Date must not be empty or null",
                              status: ToastStatus.Error,
                            );
                          }
                        });
                      },
                      icondata: Iconsax.calendar,
                      myCrypto: 'Daily \nTransactions',
                      count: '260',
                      label: 'Categories',
                      icon: LucideIcons.shapes,
                      backgroundColor: const Color(0xFF387F36),
                      iconColor: Colors.black,
                      textColor: Colors.black,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(40),
                        bottomLeft: Radius.circular(80),
                        bottomRight: Radius.circular(20),
                      ),
                      height: cardHeight,
                    ),
                    recentTransaction(
                      ontap: () {
                        datecontroller.clear();
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.parse('2022-01-01'),
                          lastDate: DateTime.parse('2040-01-01'),
                        ).then((value) async {
                          if (value != null) {
                            var selectedDate = value.toString().split(' ')[0];
                            try {
                              await context
                                  .read<FactureController>()
                                  .getReportByDate(selectedDate)
                                  .then((value) {
                                // print(value.length.toString());
                                _openReportByDateOrBetween(value, selectedDate);
                              });
                            } catch (e) {
                              showToast(
                                message: "Error getting report: $e",
                                status: ToastStatus.Error,
                              );
                            }
                          } else {
                            showToast(
                              message: "Date must not be empty or null",
                              status: ToastStatus.Error,
                            );
                          }
                        });
                      },
                      icondata: Iconsax.calendar,
                      myCrypto: 'Daily \nTransactions',
                      count: '40',
                      label: 'Receipt',
                      icon: LucideIcons.fileText,
                      backgroundColor: const Color(0xFF387F36),
                      iconColor: Colors.black,
                      textColor: Colors.black,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(80),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(20),
                      ),
                      height: cardHeight,
                    ),
                    recentTransaction(
                      ontap: () {
                        datecontroller.clear();
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.parse('2022-01-01'),
                          lastDate: DateTime.parse('2040-01-01'),
                        ).then((value) async {
                          if (value != null) {
                            var selectedDate = value.toString().split(' ')[0];
                            try {
                              await context
                                  .read<FactureController>()
                                  .getReportByDate(selectedDate)
                                  .then((value) {
                                // print(value.length.toString());
                                _openReportByDateOrBetween(value, selectedDate);
                              });
                            } catch (e) {
                              showToast(
                                message: "Error getting report: $e",
                                status: ToastStatus.Error,
                              );
                            }
                          } else {
                            showToast(
                              message: "Date must not be empty or null",
                              status: ToastStatus.Error,
                            );
                          }
                        });
                      },
                      icondata: Iconsax.calendar,
                      myCrypto: 'Daily \nTransactions',
                      count: '260',
                      label: 'Transactions',
                      icon: LucideIcons.calendar,
                      backgroundColor: const Color(0xFF2C2C2E),
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(80),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(40),
                      ),
                      height: cardHeight,
                    ),
                    // Add more recentTransaction widgets as needed
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _myDrawer(AuthController _controller, BuildContext context) {
    String? _userImage = currentuser != null ? currentuser?.photoURL : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: _userImage != null
                        ? NetworkImage("$_userImage")
                        : AssetImage(
                            "assets/images/default_image.png",
                          ) as ImageProvider,
                    fit: BoxFit.fill),
                //whatever image you can put here
              ),
            ),
            currentuser == null
                ? Icon(
                    Icons.cloud_off,
                    color: Colors.grey.shade600,
                    size: 35,
                  )
                : Icon(
                    Icons.cloud_outlined,
                    color: Colors.green.shade800,
                    size: 35,
                  ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () async {
            if (currentuser == null) {
              await _controller.signInWithGoogle().then((value) {
                showToast(
                    message: _controller.statusLoginMessage,
                    status: _controller.toastLoginStatus);
              });
            }
          },
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _controller.getDrawerTitle().toString(),
                      style: TextStyle(color: Colors.black, letterSpacing: 2),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      _controller.getDrawerSubTitle().toString(),
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              if (_controller.isloadingLogin)
                CircularProgressIndicator(
                  color: Colors.white,
                ),
            ],
          ),
        )
      ],
    );
  }


  Future<void> deleteDatabase() => databaseFactory.deleteDatabase(databasepath);
  Future<void> _openReportByDateOrBetween(
      List<DetailsFactureModel> list, String startDate,
      {String? endDate}) async {

    try {

      final pdfFile = await PdfApi.generateReport(
        list,
        startDate: startDate,
        endDate: endDate,
      );
      PdfApi.openFile(pdfFile);
    } catch (e) {
      print('Error generating PDF report: $e');
      // Handle error as needed
    }
  }
}

class recentTransaction extends StatelessWidget {
  const recentTransaction({
    super.key,
    required this.icondata,
    required this.myCrypto,
    required this.ontap,
    required this.count,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.borderRadius, required this.height,
  });

  final IconData icondata;
  final String myCrypto;
  final VoidCallback ontap;
  final String count;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final BorderRadius borderRadius;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 50,color: textColor,
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      myCrypto,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryTileCustom extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final BorderRadius borderRadius;

  const SummaryTileCustom({
    Key? key,
    required this.count,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        color: backgroundColor,
        padding: EdgeInsets.all(20),
        height: 140, // Same height for all to align
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 15),
            Text(
              count,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TileWidget extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final BorderRadius borderRadius;
  final double height;

  const TileWidget({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.borderRadius,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 40),
              const SizedBox(height: 16),
              Text(
                count,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}