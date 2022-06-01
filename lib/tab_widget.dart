import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_app/products_tab.dart';
import 'package:flutter_firebase_app/users_tab.dart';

class TabBarClass extends StatelessWidget {
  const TabBarClass({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Container(
              padding: EdgeInsets.only(right: 50),
              child: IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => FirebaseAuth.instance.signOut()
              ),
            ),
          ],
          bottom: const TabBar(
            labelPadding: EdgeInsets.all(10),
            tabs: [
              Text("Users", style: TextStyle(fontSize: 20)),
              Text("Products", style: TextStyle(fontSize: 20)),
            ],
          ),
          title: const Text('Flutter Firebase App'),
        ),
        body: const TabBarView(
          children: [
            UsersTab(),
            ProductsTab(),
          ],
        ),
      ),
    );
  }
}
