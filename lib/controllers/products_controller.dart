import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:myinventory/models/details_facture.dart';
import 'package:myinventory/models/facture.dart';
import 'package:myinventory/models/product.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/local/marketdb_helper.dart';
import 'package:myinventory/shared/toast_message.dart';

class ProductsController extends ChangeNotifier {
  MarketDbHelper marketdb = MarketDbHelper.db;

  List<ProductModel> _list_ofProduct = [];
  List<ProductModel> get list_ofProduct => _list_ofProduct;
  List<ProductModel> _original_List_Of_product = [];

  bool isloadingGetProducts = false;
  
  double _totalAmountSold = 0;
  int _totalItemsSold = 0;
  int _totalTransactions = 0;
  int _totalStock = 0;

  double get totalAmountSold => _totalAmountSold;
  int get totalItemsSold => _totalItemsSold;
  int get totalTransactions => _totalTransactions;
  int get totalStock => _totalStock;

  ProductsController() {
    getTotalSalesData();
  }

  Future<List<ProductModel>> getAllProduct() async {
    isloadingGetProducts = true;
    notifyListeners();
    _list_ofProduct = [];
    var dbm = await marketdb.database;

    await dbm
        .rawQuery("select * from products order by name limit 200")
        .then((value) {
      for (var element in value) {
        _list_ofProduct.add(ProductModel.fromJson(element));
      }
      _original_List_Of_product = _list_ofProduct;
      isloadingGetProducts = false;
      notifyListeners();
    });
    return _list_ofProduct;
  }

  Future<void> deleteProduct(ProductModel model) async {
    var dbm = await marketdb.database;
    await dbm
        .rawDelete("DELETE FROM products where barcode='${model.barcode}'")
        .then((value) {
      _list_ofProduct.removeWhere((element) => element.barcode == model.barcode);
      notifyListeners();
      getTotalSalesData();
    }).catchError((error) {
      print(error.toString());
    });
  }

  var statusInsertBodyMessage = "";
  var statusInsertMessage = ToastStatus.Error;

  Future<void> insertProductByModel({required ProductModel model}) async {
    var dbm = await marketdb.database;
    await dbm
        .rawQuery("select * from products where barcode='${model.barcode}'")
        .then((value) async {
      if (value.isNotEmpty) {
        ProductModel productModel = ProductModel.fromJson(value[0]);
        int newqty = int.parse(model.qty.toString()) + int.parse(productModel.qty.toString());
        int totalprice = (int.tryParse(model.totalprice.toString()) ?? 0) + (int.tryParse(productModel.totalprice.toString()) ?? 0);
        
        productModel.qty = newqty.toString();
        productModel.price = model.price;
        productModel.totalprice = totalprice.toString();

        await updateProduct(productModel).then((value) {
          statusInsertBodyMessage = " ${model.name} updated Successfully";
          statusInsertMessage = ToastStatus.Success;
        });
      } else {
        await dbm.insert("products", model.toJson());
        statusInsertBodyMessage = "product inserted successfully";
        statusInsertMessage = ToastStatus.Success;
        _list_ofProduct.add(model);
      }
      getTotalSalesData();
      notifyListeners();
    });
  }

  var statusUpdateBodyMessage = "";
  var statusUpdateMessage = ToastStatus.Error;

  Future<void> updateProduct(ProductModel model) async {
    var dbm = await marketdb.database;
    await dbm
        .rawUpdate(
            "UPDATE products SET barcode= '${model.barcode}', name= '${model.name}' , price= '${model.price}', qty='${model.qty}' , totalprice='${model.totalprice}' ,profit_per_item='${model.profit_per_item}' where  barcode='${model.barcode}'")
        .then((value) async {
      statusUpdateBodyMessage = " ${model.name} updated Successfully";
      statusUpdateMessage = ToastStatus.Success;
      _updateProductInUI(model);
      getTotalSalesData();
    }).catchError((error) {
      print(error.toString());
    });
  }

  _updateProductInUI(ProductModel model) {
    for (var element in _list_ofProduct) {
      if (element.barcode == model.barcode) {
        element.name = model.name;
        element.price = model.price;
        element.qty = model.qty;
        element.profit_per_item = model.profit_per_item;
      }
    }
    notifyListeners();
  }

  clearSearch() {
    _list_ofProduct = _original_List_Of_product;
    notifyListeners();
  }

  Future<void> search_In_Products(String value) async {
    isloadingGetProducts = true;
    notifyListeners();
    _list_ofProduct = [];
    var dbm = await marketdb.database;

    await dbm
        .rawQuery("select * from products where name LIKE '%$value%'")
        .then((value) {
      for (var element in value) {
        _list_ofProduct.add(ProductModel.fromJson(element));
      }
      isloadingGetProducts = false;
      notifyListeners();
    });
  }

  List<ProductModel> basket_products = [];

  Future<bool> fetchProductBybarCode(String barcode) async {
    var dbm = await marketdb.database;
    bool isExist = false;

    await dbm
        .rawQuery("select * from products where barcode = '$barcode'")
        .then((value) {
      if (value.isNotEmpty) {
        isExist = true;
        for (var element in value) {
          var p = ProductModel.fromJson(element);
          p.qty = "1";
          basket_products.add(p);
        }
      }
      gettotalPrice();
      notifyListeners();
    });
    return isExist;
  }

  bool isProductExist = false;
  Future<ProductModel?> getProductbyBarcode(String barcode) async {
    var dbm = await marketdb.database;
    ProductModel? model;

    await dbm
        .rawQuery("select * from products where barcode = '$barcode'")
        .then((value) {
      if (value.isNotEmpty) {
        isProductExist = true;
        model = ProductModel.fromJson(value[0]);
      } else {
        isProductExist = false;
      }
      notifyListeners();
    });
    return model;
  }

  Future<bool> onchangeQtyInBasket(String barcode, String qty) async {
    bool isonchangesuccess = true;
    ProductModel? model = await getProductbyBarcode(barcode);
    if (model != null && int.parse(model.qty.toString()) >= int.parse(qty)) {
      for (var element in basket_products) {
        if (element.barcode == barcode) element.qty = qty;
      }
      isonchangesuccess = true;
    } else {
      isonchangesuccess = false;
    }
    gettotalPrice();
    notifyListeners();
    return isonchangesuccess;
  }

  double totalprice = 0;
  gettotalPrice() {
    totalprice = 0;
    for (var element in basket_products) {
      totalprice += int.parse(element.qty.toString()) * int.parse(element.price.toString());
    }
    notifyListeners();
  }

  deleteProductFromBasket(String barcode) {
    basket_products.removeWhere((element) => element.barcode == barcode);
    gettotalPrice();
    notifyListeners();
  }

  clearBasket() {
    basket_products = [];
    totalprice = 0;
    notifyListeners();
  }

  Future<void> addFacture() async {
    var dbm = await marketdb.database;

    FactureModel factureModel = FactureModel(price: totalprice.toString(), facturedate: gettodayDate());
    int facture_id = await dbm.insert("factures", factureModel.toJson());

    for (var element in basket_products) {
      int itemTotalPrice = (int.parse(element.qty.toString()) * int.parse(element.price.toString()));
      DetailsFactureModel detailsFactureModel = DetailsFactureModel(
          barcode: element.barcode,
          name: element.name,
          qty: element.qty,
          price: itemTotalPrice.toString(),
          facture_id: facture_id,
          profit_per_item_on_sale: element.profit_per_item);

      ProductModel? productModel = await getProductbyBarcode(element.barcode.toString());
      int newqty = 0;
      if (productModel != null) {
        newqty = int.parse(productModel.qty.toString()) - int.parse(element.qty.toString());
        productModel.qty = newqty.toString();
        _updateProductInUI(productModel);
      }

      await dbm.rawUpdate("update products set qty=? where barcode=?", ['$newqty', '${element.barcode}']);
      await dbm.insert('detailsfacture', detailsFactureModel.toJson());
    }
    clearBasket();
    getTotalSalesData();
  }

  Future<void> getTotalSalesData() async {
    var dbm = await marketdb.database;

    await dbm.rawQuery("SELECT SUM(qty) as totalItems, SUM(price) as totalAmount FROM detailsfacture").then((value) {
      if (value.isNotEmpty) {
        _totalItemsSold = int.tryParse(value[0]['totalItems'].toString()) ?? 0;
        _totalAmountSold = double.tryParse(value[0]['totalAmount'].toString()) ?? 0.0;
      }
    });

    await dbm.rawQuery("SELECT COUNT(*) as count FROM factures").then((value) {
      if (value.isNotEmpty) {
        _totalTransactions = int.tryParse(value[0]['count'].toString()) ?? 0;
      }
    });

    await dbm.rawQuery("SELECT SUM(qty) as stock FROM products").then((value) {
      if (value.isNotEmpty) {
        _totalStock = int.tryParse(value[0]['stock'].toString()) ?? 0;
      }
    });

    notifyListeners();
  }

  Future<List<ProductModel>> autocomplete_Search_forProduct(String value) async {
    List<ProductModel> results = [];
    var dbm = await marketdb.database;
    await dbm.rawQuery("select * from products where name LIKE '%$value%'").then((value) {
      for (var element in value) {
        results.add(ProductModel.fromJson(element));
      }
    });
    return results;
  }

  Future<void> cleanDatabase() async {
    var dbm = await marketdb.database;
    await dbm.rawDelete("DELETE FROM products");
    await dbm.rawDelete("DELETE FROM factures");
    await dbm.rawDelete("DELETE FROM detailsfacture");
    _list_ofProduct = [];
    getTotalSalesData();
    notifyListeners();
  }
}
