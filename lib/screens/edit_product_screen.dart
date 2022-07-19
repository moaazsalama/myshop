import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static String routname = "/edit-screen";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var _initialValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var _isInit = true;
  var _isLoading = false;
  @override
  void initState() {
    super.initState();
    _imageUrlNode.addListener(_updateImageUrl);
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlNode.removeListener(_updateImageUrl);
    _priceNode.dispose();
    _imageUrlNode.dispose();
    _imageUrlController.dispose();
    _descriptionNode.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      if (productId != null) {
        _editProduct = Provider.of<Products>(context).findItemById(productId);
        _initialValue = {
          'title': _editProduct.title!,
          'description': _editProduct.description!,
          'price': _editProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editProduct.imageUrl!;
      }
      _isInit = false;
    }
  }

  void _updateImageUrl() {
    if (!_imageUrlNode.hasFocus) {
      if (_imageUrlController.text.startsWith('http') &&
              _imageUrlController.text.startsWith('https') ||
          (_imageUrlController.text.endsWith('.png')) &&
              (_imageUrlController.text.endsWith('.jpg')) &&
              (_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isvalid = _formKey.currentState!.validate();
    if (!isvalid) return null;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id!, _editProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProducts(_editProduct);
      } catch (e) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("There is Something Wrong "),
            title: Text("Error"),
            actions: [
              FlatButton(
                  child: Text("Okay!"),
                  onPressed: () => Navigator.of(context).pop())
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EditProductScreen"),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Title",
                      ),
                      initialValue: _initialValue['title'],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        Focus.of(context).requestFocus(_priceNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) return "Please Provide A Value";
                        return null;
                      },
                      onSaved: (newValue) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            title: newValue,
                            description: _editProduct.description,
                            price: _editProduct.price,
                            imageUrl: _editProduct.imageUrl);
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      focusNode: _priceNode,
                      decoration: InputDecoration(
                        hintText: "Price",
                      ),
                      initialValue: _initialValue['price'],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        Focus.of(context).requestFocus(_descriptionNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) return "Enter Price Please";
                        if (double.tryParse(value) == null)
                          return "Please Provide A Value";
                        if (double.parse(value) <= 0)
                          return "low Price \nplease Enter Suitable Price";
                        return null;
                      },
                      onSaved: (newValue) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: _editProduct.description,
                            price: double.parse(newValue!),
                            imageUrl: _editProduct.imageUrl);
                      },
                    ),
                    TextFormField(
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionNode,
                      decoration: InputDecoration(
                        hintText: "Description",
                      ),
                      initialValue: _initialValue['description'],
                      validator: (value) {
                        if (value!.isEmpty) return "Enter Price Please";
                        if (value.length <= 10) {
                          return "low length \nplease Enter description more than 10 charactars";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: newValue,
                            price: _editProduct.price,
                            imageUrl: _editProduct.imageUrl);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter Image Url")
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration: InputDecoration(
                              hintText: "Image Url",
                            ),
                            validator: (value) {
                              if (!value!.startsWith('http') &&
                                  !value.startsWith('https'))
                                return "Enter Valid Url Please1";
                              if (!value.endsWith('png') &&
                                  !value.endsWith('jpg') &&
                                  !value.endsWith('jpeg'))
                                return "Enter Valid Url Please2";
                              return null;
                            },
                            onSaved: (newValue) {
                              _editProduct = Product(
                                  id: _editProduct.id,
                                  title: _editProduct.title,
                                  description: _editProduct.description,
                                  price: _editProduct.price,
                                  imageUrl: newValue);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
