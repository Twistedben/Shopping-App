import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/add-product';

  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode =
      FocusNode(); // FocusNOdes should always be disposed, as they stick around and will cause memory leaks
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>(); // Allows Form access
  var _editedProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');
  var _isInit =
      true; // Makes sure didChangeDependencise only runs once for our functions
  var _initValues = {
    'id': null,
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isLoading = false;
  //Set up a listener for loss of focus on image url so we can render preview if they click off
  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments
          as String; // Is ID from user_product_Item
      if (productId != null) {
        // We do have a product id, existing
        _editedProduct = Provider.of<Products>(context, listen: false).findById(
            productId); // Aggigns the existing, editing, product to product
        _initValues = {
          // Text input only works with strings
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        }; // Overrides the initial empty values of product ot the existing edited one
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
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

  // If image url input loses focus, then execute to load image preview in and validate image input
  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {
        // Is a hack since it just rebuilds the widget
      });
    }
  }

  // We use a global key since we need to interact with a widget inside our tree, set up above. Function triggers a save on every text field inside the form below.
  Future<void> _saveForm() async { 
  //void _saveForm() { // Used doing then() and catchError()
    final isValid =
        _form.currentState.validate(); // Runs the validate: props on each input
    if (!isValid) {
      // FOrm is not valid, so breaks out of function
      return;
    }
    _form.currentState.save(); // Saves the form's values
    setState(() {
      // Sets _isLoading so indicator is shown
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      // Checks if existing product being edited so a new entry is'n't created, instead updates one
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct); // Adds the product
      setState(() {
        // Sets _isLoading so indicator is not show
        _isLoading = false;
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false) // No final result = here because addProduct returns nothing, so we don't need to store it in a variable 
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(           // Show a dialog box to indicate an error has occured saving the product and a button to exit screen. We do a return here to resolve the future so that it doesn't execute immediately and will navigator.pop when Okay is pressed, then moving onto then()
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occured!'),
            content: Text('Something went wrong'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      } finally {   // Executes no matter what in a try and catch
        setState(() {
          // Sets _isLoading so indicator is not show
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }
      // Provider.of<Products>(context, listen: false) // No final result = here because addProduct returns nothing, so we don't need to store it in a variable 
      //     .addProduct(_editedProduct)
      //     .catchError((error) {
      //   return showDialog(           // Show a dialog box to indicate an error has occured saving the product and a button to exit screen. We do a return here to resolve the future so that it doesn't execute immediately and will navigator.pop when Okay is pressed, then moving onto then()
      //     context: context,
      //     builder: (ctx) => AlertDialog(
      //       title: Text('An error occured!'),
      //       content: Text('Something went wrong'),
      //       actions: <Widget>[
      //         FlatButton(
      //           child: Text('Okay'),
      //           onPressed: () {
      //             Navigator.of(ctx).pop();
      //           },
      //         )
      //       ],
      //     ),
      //   );
      // }) // Has the error thrown in products.dart. The then() future will still be executed since it comes after the catchError, and in this case, that's what we want, and it's executing due to the future being returned by the catchError()
      //     .then((_) {
      //   setState(() {
      //     // Sets _isLoading so indicator is not show
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }); // Adds the product. Is a Future declared in products.dart, since the future returns void, we just use _ to show we don't work with it. Now we'll navigate away only once the future resolves and product is added in firebase
    // }
  // }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed:
                _saveForm, // Submits the form using the method defined above
          )
        ],
      ),
      body:
          _isLoading // If _isLoading is true, show a circle progress indicator, otherwise show form
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _form,
                    child: ListView(
                      // Another option is for longer forms is singlechildscrollview and column:  child: SingleChildScrollView(child: Column(children: [ ... ],
                      children: <Widget>[
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration: InputDecoration(labelText: 'Title'),
                          textInputAction: TextInputAction
                              .next, // COntrols what bottom right button will be on keyboard. Next will move to next input instead of submitting form
                          onFieldSubmitted: (value) {
                            // Fires when the bnottom right button is pressed
                            FocusScope.of(context).requestFocus(
                                _priceFocusNode); // Tells it now to go to Price input when next is clicked
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: value,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: _editedProduct.imageUrl);
                          },
                          validator: (value) {
                            // Returning null means input is valid, returning String is error text
                            if (value.isEmpty) {
                              return "Please provide a title"; // Error message. In InputDecoration, the error props can be configured.
                            }
                            return null; // No error
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (value) {
                            // Fires when the bnottom right button is pressed
                            FocusScope.of(context).requestFocus(
                                _descriptionFocusNode); // Tells it now to go to Price input when next is clicked
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                price: double.parse(value),
                                description: _editedProduct.description,
                                imageUrl: _editedProduct.imageUrl);
                          },
                          validator: (value) {
                            // Returning null means input is valid, returning String is error text
                            if (value.isEmpty) {
                              return "Please enter a price"; // Error message. In InputDecoration, the error props can be configured.
                            }
                            if (double.tryParse(value) == null) {
                              return "Please enter a valid number";
                            }
                            if (double.parse(value) <= 0) {
                              return "Please enter a price greater than 0";
                            }
                            return null; // No error
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines:
                              3, // How many lines rendered on screen, bigger text field
                          keyboardType: TextInputType
                              .multiline, // Allows enter symbol on keyboard for new paragrapgh
                          focusNode: _descriptionFocusNode,
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: value,
                                imageUrl: _editedProduct.imageUrl);
                          },
                          validator: (value) {
                            // Returning null means input is valid, returning String is error text
                            if (value.isEmpty) {
                              return "Please enter a description"; // Error message. In InputDecoration, the error props can be configured.
                            }
                            if (value.length < 10) {
                              return "Description minimum characters is 10"; // Error message. In InputDecoration, the error props can be configured.
                            }
                            return null; // No error
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              child: _imageUrlController.text.isEmpty
                                  ? Text('Enter Image URL')
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                // initialValue: _initValues['imageUrl'], Since we use a controller, cannot use initial value, instead set the _imageController = to the existing
                                decoration:
                                    InputDecoration(labelText: 'Image Url'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller:
                                    _imageUrlController, // We want the value before form is submitted so we use a controller
                                focusNode: _imageUrlFocusNode,
                                onSaved: (value) {
                                  _editedProduct = Product(
                                      id: _editedProduct.id,
                                      isFavorite: _editedProduct.isFavorite,
                                      title: _editedProduct.title,
                                      price: _editedProduct.price,
                                      description: _editedProduct.description,
                                      imageUrl: value);
                                },
                                onFieldSubmitted: (_) {
                                  _saveForm();
                                },
                                validator: (value) {
                                  // Returning null means input is valid, returning String is error text
                                  if (value.isEmpty) {
                                    return "Please enter a URL to an image"; // Error message. In InputDecoration, the error props can be configured.
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    return "Please enter a valid URL to an image"; // Error message. In InputDecoration, the error props can be configured.
                                  }
                                  if (!value.endsWith('.png') &&
                                      !value.endsWith('.jpg') &&
                                      !value.endsWith('.jpeg')) {
                                    return "Please enter an image URL to a .jpg, .png, or .jpeg"; // Error message. In InputDecoration, the error props can be configured.
                                  }
                                  return null; // No error
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
