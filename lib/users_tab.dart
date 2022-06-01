import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_app/db_instance.dart';
import 'package:flutter_firebase_app/models/classes.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<User> users = [];

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  void _addUserDB() {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        phoneController.text.isEmpty)
      return print(
          'adding to db: name=${nameController.text} address=${addressController.text} phone=${phoneController.text}');
    db.collection("users").add({
      "name": nameController.text,
      "address": addressController.text,
      "phone": num.parse(phoneController.text),
    }).then((doc) => print('DocumentSnapshot added with ID: ${doc.id}'),
        onError: (error) => print(error));
    nameController.text = "";
    addressController.text = "";
    phoneController.text = "";
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
          stream: db.collection("users").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                            Center(
                                child:
                                    Text(snapshot.data?.docs[index]['name'])),
                            Center(
                                child: Text(
                                    snapshot.data?.docs[index]['address'])),
                            Center(
                                child: Text(snapshot.data?.docs[index]['phone']
                                    .toString() as String)),
                            Center(
                              child: IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Remove User',
                                onPressed: () => db
                                    .collection("users")
                                    .doc(snapshot.data?.docs[index].id)
                                    .delete()
                                    .onError(
                                        (error, stackTrace) => print(error)),
                              ),
                            )
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
              title: const Text('Add new user'),
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
                        labelText: 'Address',
                      ),
                      controller: addressController,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Phone',
                      ),
                      controller: phoneController,
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
                  onPressed: _addUserDB,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          tooltip: 'Add user',
          child: const Icon(Icons.add),
        ),
      );
  }
}