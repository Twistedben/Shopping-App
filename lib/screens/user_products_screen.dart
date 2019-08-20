import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.add), onPressed: () {

          },),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(8),
       child: ListView.builder(itemCount: productsData.items.length, itemBuilder: (_, index) => null,),),
    );
  }
}