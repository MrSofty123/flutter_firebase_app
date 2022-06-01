class User {
  String id = "undefined";
  String name = "undefined";
  String address = "undefined";
  num phone = 0;

  User(
      {required this.id,
      required this.name,
      required this.address,
      required this.phone});
}

class Product {
  String id = "undefined";
  String name = "undefined";
  String weight = "undefined";
  num price = 0;

  Product({required this.id, required this.name, required this.weight, required this.price});
}
