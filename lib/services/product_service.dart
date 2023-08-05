import 'dart:convert';
import 'dart:io';

import 'package:crud_rest_camara/models/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductService extends ChangeNotifier {
  final String _baseUrl = 'flutter-varios-d13e7-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  late Product selectedProduct;

  File? newpictureFile;

  bool isLoading = true;
  bool isSaving = false;
  //Todo hacer fetch de prodcutos
  ProductService() {
    this.loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    this.isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(resp.body);
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromJson(value);
      tempProduct.id = key;

      this.products.add(tempProduct);
    });
    this.isLoading = false;
    notifyListeners();

    return this.products;
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.id == null) {
      //!Necesario crear
      await this.createProduct(product);
    } else {
      await this.updateProduct(product);
      //!Actualizar
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    //! si muestra error observar el modelo para añadir toRawJson o toJson
    final resp = await http.put(url, body: product.toRawJson());
    final decodedData = resp.body;

    //print(decodedData);

    //?Regresa el indice del producto dcuyo id es igual que se recibe aqui
    final index =
        this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    //! si muestra error observar el modelo para añadir toRawJson o toJson
    final resp = await http.post(url, body: product.toRawJson());
    final decodedData = json.decode(resp.body);

    product.id = decodedData['name'];

    this.products.add(product);

    return product.id!;
  }

  void updateSelectedProductImage(String path) {
    this.selectedProduct.picture = path;
    this.newpictureFile = File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (this.newpictureFile == null) return null;

    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dm5hlqddr/image/upload?upload_preset=ml_default');

    final imageIploadRequest = http.MultipartRequest('POST', url);

    final file =
        await http.MultipartFile.fromPath('file', newpictureFile!.path);

    imageIploadRequest.files.add(file);

    final streamResponse = await imageIploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('algo salio mal');
      print(resp.body);
      return null;
    }

    this.newpictureFile = null;

    final responseData = json.decode(resp.body);
    //print(resp.body);

    return responseData['secure_url'];
  }
}
