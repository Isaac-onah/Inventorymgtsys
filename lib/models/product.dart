class ProductModel {
  String barcode;
  String name;
  String price;
  String totalprice;
  String qty = "1";
  String profit_per_item = "";

  ProductModel(
      {required this.barcode,
      required this.name,
      required this.price,
      required this.totalprice,
      required this.qty,
      required this.profit_per_item});

  factory ProductModel.fromJson(Map<String, dynamic> map) {
    return ProductModel(
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toString() ?? '0',
      totalprice: map['totalprice']?.toString() ?? '0',
      qty: map['qty']?.toString() ?? '0',
      profit_per_item: map['profit_per_item']?.toString() ?? '0',
    );
  }
  toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'price': price,
      'totalprice': totalprice,
      'qty': qty,
      'profit_per_item': profit_per_item,
    };
  }
}
