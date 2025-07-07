import 'package:cloud_firestore/cloud_firestore.dart';

class DBProductModel{

  String? _nameProduct;
  String? _descriptionProduct;
  String? _imageProduct;
  String? _priceProduct;
  String? _quantityProduct;
  String? _uid;

  DBProductModel();

  DBProductModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    nameProduct = documentSnapshot["nome"];
    descriptionProduct = documentSnapshot["descricao"];
    imageProduct = documentSnapshot["imagem"];
    priceProduct = documentSnapshot["preco"];
    quantityProduct = documentSnapshot["quantidade"];
    uid = documentSnapshot["uid"];
  }

  Map<String, dynamic> toMap(uid){
    Map<String, dynamic> map = {
      "uid": uid,
      "nome": _nameProduct,
      "descricao": _descriptionProduct,
      "imagem": _imageProduct,
      "preco": _priceProduct,
      "quantidade": _quantityProduct
    };
    return map;

  }

  String get uid => _uid!;

  set uid(String value) {
    _uid = value;
  }

  String get quantityProduct => _quantityProduct!;

  set quantityProduct(String value) {
    _quantityProduct = value;
  }

  String get priceProduct => _priceProduct!;

  set priceProduct(String value) {
    _priceProduct = value;
  }

  String get imageProduct => _imageProduct!;

  set imageProduct(String value) {
    _imageProduct = value;
  }

  String get descriptionProduct => _descriptionProduct!;

  set descriptionProduct(String value) {
    _descriptionProduct = value;
  }

  String get nameProduct => _nameProduct!;

  set nameProduct(String value) {
    _nameProduct = value;
  }
}