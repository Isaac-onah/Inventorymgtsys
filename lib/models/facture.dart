class FactureModel {
  String? id;
  String? price;
  String? facturedate;
  String? itemNames;

  FactureModel({required this.price, required this.facturedate, this.itemNames});

  FactureModel.fromJson(Map<String, dynamic> map) {
    id = map['id'] != null ? map['id'].toString() : '';
    price = map['price'] != null ? map['price'].toString() : '';
    facturedate =
        map['facturedate'] != null ? map['facturedate'].toString() : '';
    itemNames = map['itemNames'] != null ? map['itemNames'].toString() : '';
  }

  toJson() {
    return {'price': price, 'facturedate': facturedate};
  }
}
