import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_app/db_instance.dart';
import 'package:flutter_firebase_app/models/classes.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final priceController = TextEditingController();

  void _addProductDB() async {
    if (weightController.text.isEmpty ||
        priceController.text.isEmpty ||
        nameController.text.isEmpty) return;
    if (await db
        .collection("products")
        .doc(nameController.text)
        .get()
        .then((value) => value.exists)) {
      print('document already exists.');
      return;
    }
    print(
        'adding to db: name=${nameController.text} weight=${weightController.text} price=${priceController.text}');
    db.collection("products").doc(nameController.text).set(
      {
        "weight": weightController.text,
        "price": num.parse(priceController.text),
      },
    ).then(
        (res) =>
            print('DocumentSnapshot added with ID: ${nameController.text}'),
        onError: (error) => print(error));
    nameController.text = "";
    weightController.text = "";
    priceController.text = "";
    Navigator.pop(context, 'Cancel');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection("products").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: const CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text('Error');
            } else if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 50,
                      color: Colors.amber[600],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(snapshot.data?.docs[index].id as String),
                          Text(snapshot.data?.docs[index]['weight']),
                          Text(snapshot.data?.docs[index]['price'].toString()
                              as String),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Remove Product',
                            onPressed: () => db
                                .collection("products")
                                .doc(snapshot.data?.docs[index].id)
                                .delete()
                                .onError((error, stackTrace) => print(error)),
                          ),
                        ],
                      ),
                    );
                  });
            } else {
              return const Text('Empty data');
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Add new product'),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Name',
                    ),
                    controller: nameController,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Weight',
                    ),
                    controller: weightController,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Price',
                    ),
                    controller: priceController,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _addProductDB,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
