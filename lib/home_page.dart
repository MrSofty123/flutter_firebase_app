
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_app/db_instance.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<user> users = [];

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  void _addUserDB() {
      print('hi');
      print('adding to db: name=${nameController.text} address=${addressController
          .text} phone=${phoneController.text}');
      db.collection("users").add({
        "name": nameController.text,
        "address": addressController.text,
        "phone": num.parse(phoneController.text),
      }).then((doc) => print('DocumentSnapshot added with ID: ${doc.id}'), onError: (error) => print(error));
      nameController.text = "";
      addressController.text = "";
      phoneController.text = "";
      Navigator.pop(context, 'Cancel');
  }

  void _removeUserDB(user userObj) {
    db.collection("users").doc(userObj.id).delete().onError((error, stackTrace) => print(error));
  }


  void initState() {
    db.collection("users").snapshots().listen((event) {
      print('listener called');
      event.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          print('adding user');
          users.add(
              user(
                  id: change.doc.id,
                  address: change.doc.data()?['address'],
                  phone: change.doc.data()?['phone'],
                  name: change.doc.data()?['name'])
          );
        }
        if (change.type == DocumentChangeType.removed) {
          print('removing');
          users.removeWhere((user) => user.id == change.doc.id);
        }
      });
      setState(() {
        users: this.users;
      });
    });
  }

  // Listen to database updates

  List<Widget> _computeUsersList() {
    print('computing users list');
    //something
    List<Container> temp = [];
    users.forEach((user element) {
      temp.add(Container(
        height: 50,
        color: Colors.amber[600],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(child: Text(element.name)),
            Center(child: Text(element.address)),
            Center(child: Text(element.phone.toString())),
            Center(child: IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Remove User',
              onPressed: () => _removeUserDB(element),
            ),)
          ],
        ),
      ));
    });
    return temp;
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
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: _computeUsersList(),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Add new user'),
            content: Container(
              height: MediaQuery.of(context).size.height*0.3,
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class user {
  String id = "undefined";
  String name = "undefined";
  String address = "undefined";
  num phone = 0;

  user({required this.id, required this.name, required this.address, required this.phone});
}