import 'package:crud_rest_camara/models/product.dart';
import 'package:flutter/material.dart';

class ProductFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  Product product;
  //!Constructor
  ProductFormProvider(this.product);

  updateAvilability(bool value) {
    //print(value);
    this.product.available = value;
    notifyListeners();
  }

  bool isValid() {
    //print(product.name);
    //print(product.price);
    //print(product.available);
    return formKey.currentState?.validate() ?? false;
  }
}
