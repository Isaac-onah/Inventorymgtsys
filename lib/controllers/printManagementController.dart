// import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:myinventory/models/printermodel.dart';
import 'package:myinventory/models/product.dart';
import 'package:myinventory/services/printer/printer_api.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/local/cash_helper.dart';
import 'package:myinventory/shared/toast_message.dart';
import 'package:permission_handler/permission_handler.dart';

class PrintManagementController extends ChangeNotifier {
  bool isprintautomatically = false;
  PrintManagementController() {
    isprintautomatically =
        CashHelper.getData(key: 'isprintautomatically') ?? false;
    notifyListeners();
  }

  PageSize pageSize = PageSize.mm58; // default
  void onchagePageSize(value) {
    pageSize = value;
    notifyListeners();
  }

  // for printing on cash
  void onsetprintautomatically(bool value) {
    isprintautomatically = value;
    CashHelper.saveData(key: "isprintautomatically", value: value);
    if (value) {
      showToast(message: "enabled", status: ToastStatus.Success);
    } else {
      showToast(message: "disabled", status: ToastStatus.Success);
    }
    notifyListeners();
  }

  List<PrinterModel> availableBluetoothDevices = [];
  bool isloadingsearch_for_device = false;

  // Future<void> getBluetooth() async {
  //   availableBluetoothDevices = [];
  //   isloadingsearch_for_device = true;
  //   notifyListeners();
  //
  //   // Request necessary permissions
  //   if (await _requestPermissions()) {
  //     await BluetoothThermalPrinter.getBluetooths.then((value) {
  //       print("value :" + value.toString());
  //       if (value!.length > 0) {
  //         value.forEach((element) async {
  //           List list = element.toString().split('#');
  //           String name = list[0];
  //           String mac = list[1];
  //           bool isconnected = false;
  //
  //           await BluetoothThermalPrinter.connectionStatus.then((value) {
  //             print('this is $value');
  //             if (value == "true" && mac == device_mac) isconnected = true;
  //
  //             availableBluetoothDevices.add(PrinterModel(
  //                 name: name, macAddress: mac, isconnected: isconnected));
  //           }).catchError((error) {
  //             print('this is ${error.toString()}');
  //             isloadingsearch_for_device = false;
  //             notifyListeners();
  //           });
  //         });
  //       } else {
  //         showToast(message: "enable bluetooth", status: ToastStatus.Error);
  //       }
  //       isloadingsearch_for_device = false;
  //       notifyListeners();
  //     }).catchError((error) {
  //       print(error.toString());
  //       isloadingsearch_for_device = false;
  //       notifyListeners();
  //     });
  //   } else {
  //     showToast(message: "Bluetooth permissions not granted", status: ToastStatus.Error);
  //     isloadingsearch_for_device = false;
  //     notifyListeners();
  //   }
  // }

  bool isloadingconnect = false;
  //
  // Future<void> setConnect(String? mac) async {
  //   print("mac :" + mac.toString());
  //   if (mac != null) {
  //     isloadingconnect = true;
  //     notifyListeners();
  //
  //     await BluetoothThermalPrinter.connect(mac).then((value) {
  //       print("state connected $value");
  //       if (value == "true") {
  //         // change text to connected when this device is connected
  //         if (availableBluetoothDevices.length > 0)
  //           availableBluetoothDevices.forEach((element) {
  //             if (element.macAddress == mac) {
  //               element.isconnected = true;
  //             }
  //           });
  //
  //         CashHelper.saveData(key: "device_mac", value: mac);
  //       }
  //       isloadingconnect = false;
  //       notifyListeners();
  //     }).catchError((error) {
  //       print("error :" + error.toString());
  //       isloadingconnect = false;
  //       notifyListeners();
  //     });
  //   }
  // }

  // Future<void> printTicket(List<ProductModel> products,
  //     {String? cash, String? change}) async {
  //   String? isConnected = await BluetoothThermalPrinter.connectionStatus;
  //   if (isConnected == "true") {
  //     List<int> bytes = await PrintApi.getTicket(products,
  //         cash: cash, change: change, pageSize: pageSize);
  //     final result = await BluetoothThermalPrinter.writeBytes(bytes);
  //     print("Print $result");
  //   } else {
  //     if (isprintautomatically == true)
  //       showToast(message: "Printer not connected", status: ToastStatus.Error);
  //   }
  // }

  Future<bool> _requestPermissions() async {
    var statusBluetooth = await Permission.bluetooth.status;
    var statusBluetoothScan = await Permission.bluetoothScan.status;
    var statusBluetoothConnect = await Permission.bluetoothConnect.status;
    var statusLocation = await Permission.location.status;

    if (statusBluetooth.isDenied ||
        statusBluetoothScan.isDenied ||
        statusBluetoothConnect.isDenied ||
        statusLocation.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      return statuses[Permission.bluetooth]!.isGranted &&
          statuses[Permission.bluetoothScan]!.isGranted &&
          statuses[Permission.bluetoothConnect]!.isGranted &&
          statuses[Permission.location]!.isGranted;
    } else {
      return true;
    }
  }
}

enum PageSize { mm58, mm80 }
