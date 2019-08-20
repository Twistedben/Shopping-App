import 'package:flutter/material.dart';

import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/add-product';

  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode(); // FocusNOdes should always be disposed, as they stick around and will cause memory leaks
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>(); // Allows Form access 
  var _editedProduct = Product(id: null, title: '', price: 0.0, description: '', imageUrl: '');

  //Set up a listener for loss of focus on image url so we can render preview if they click off
  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
  }

  // If image url input loses focus, then execute 
  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {
         // Is a hack since it just rebuilds the widget
      });
    }
  }

  // We use a global key since we need to interact with a widget inside our tree, set up above. Function triggers a save on every text field inside the form below.
  void _saveForm() {
    _form.currentState.save();
    print(_editedProduct.title);
    print(_editedProduct.description);
    print(_editedProduct.price);
    print(_editedProduct.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm, // Submits the form using the method defined above
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            // Another option is for longer forms is singlechildscrollview and column:  child: SingleChildScrollView(child: Column(children: [ ... ],
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next, // COntrols what bottom right button will be on keyboard. Next will move to next input instead of submitting form
                onFieldSubmitted: (value) { // Fires when the bnottom right button is pressed
                  FocusScope.of(context).requestFocus(_priceFocusNode); // Tells it now to go to Price input when next is clicked
                },
                onSaved: (value) {
                  _editedProduct = Product(id: null, title: value, price: _editedProduct.price, description: _editedProduct.description, imageUrl: _editedProduct.imageUrl);
                },

              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (value) { // Fires when the bnottom right button is pressed
                  FocusScope.of(context).requestFocus(_descriptionFocusNode); // Tells it now to go to Price input when next is clicked
                },
                onSaved: (value) {
                  _editedProduct = Product(id: null, title: _editedProduct.title, price: double.parse(value), description: _editedProduct.description, imageUrl: _editedProduct.imageUrl);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3, // How many lines rendered on screen, bigger text field
                keyboardType: TextInputType.multiline, // Allows enter symbol on keyboard for new paragrapgh
                focusNode: _descriptionFocusNode,
                onSaved: (value) {
                  _editedProduct = Product(id: null, title: _editedProduct.title, price: _editedProduct.price, description: value, imageUrl: _editedProduct.imageUrl);
                }
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100, 
                    height: 100,
                    margin: const EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey,),
                    ),
                    child: _imageUrlController.text.isEmpty ? Text('Enter Image URL') : FittedBox(child: Image.network(_imageUrlController.text, fit: BoxFit.cover,),),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image Url'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController, // We want the value before form is submitted so we use a controller
                      focusNode: _imageUrlFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(id: null, title: _editedProduct.title, price: _editedProduct.price, description: _editedProduct.description, imageUrl: value);
                      },
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
