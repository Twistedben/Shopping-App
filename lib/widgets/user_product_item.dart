import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id, title, imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    // WE store scaffold here to create a type of shadow of the context so that we can use a future below to show a snackbar on delete failure
    final scaffold = Scaffold.of(context);
    return Card(
      child: ListTile(
        title: Text(title),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeName, arguments: id);
                  },
                  color: Theme.of(context).primaryColor),
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    try {
                      await Provider.of<Products>(context, listen: false)
                          .deleteProduct(id);
                    } catch (error) {
                      scaffold.showSnackBar(SnackBar(
                        content: Text('Deleting failed!', textAlign: TextAlign.center,),
                      ));
                    }
                  },
                  color: Theme.of(context).errorColor),
            ],
          ),
        ),
      ),
    );
  }
}
