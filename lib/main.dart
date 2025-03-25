import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myinventory/controllers/auth_controller.dart';
import 'package:myinventory/controllers/facture_controller.dart';
import 'package:myinventory/controllers/layout_controller.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/firebase_options.dart';
import 'package:myinventory/screens/splash_screen/splash_screen.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/local/cash_helper.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await MarketDbHelper.db.init().then((value) async {
  //   await getDatabasesPath().then((value) {
  //     print(value + "/Market.db");
  //     databasepath = value + "/Market.db";
  //   });
  // });

  // Initialize the locale data
  await initializeDateFormatting('en_US', null);

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      name: 'driver',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await CashHelper.init();

  currentuser = await CashHelper.getUser() ?? null;

  device_mac = await CashHelper.getData(key: "device_mac") ?? null;
  print("device_mac " + device_mac.toString());

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<LayoutController>(
          create: (_) => LayoutController()),
      ChangeNotifierProvider<ProductsController>(
          create: (_) => ProductsController()),
      ChangeNotifierProvider<FactureController>(
          create: (_) => FactureController()),
      ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      home: SplashScreen(),
    );
  }
}
