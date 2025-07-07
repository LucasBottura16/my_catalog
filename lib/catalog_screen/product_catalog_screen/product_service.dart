import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/models/product_model.dart';
import 'package:my_catalog/utils/random_key.dart';

class ProductService {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<Stream<QuerySnapshot>?>? addListenerProducts(
      StreamController<QuerySnapshot> controllerStream,
      String uidCompany) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Stream<QuerySnapshot> stream = firestore
        .collection("Catalogos")
        .doc(uidCompany)
        .collection("Produtos")
        .snapshots();

    stream.listen((event) {
      controllerStream.add(event);
    });

    return null;
  }

  static Future<void> deleteProduct(
    BuildContext context,
    String uidCatalog,
    String uidProduct,
    String nameProduct,
  ) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Deletar Produto"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [Text("Quer deletar o produto $nameProduct?")],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    firestore
                        .collection("Catalogos")
                        .doc(uidCatalog)
                        .collection("Produtos")
                        .doc(uidProduct)
                        .delete();
                    Navigator.pop(context);
                  },
                  child: const Text("Deletar"),
                ),
              ]);
        });
  }

  static Future<void> addProduct(
      BuildContext context,
      String uidCatalog,
      String nameProduct,
      String descriptionProduct,
      String priceProduct,
      String quantityProduct,
      String imageProduct) async {
    if (nameProduct == "" ||
        descriptionProduct == "" ||
        imageProduct == "" ||
        quantityProduct == "" ||
        priceProduct == "") {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Erro ao cadastrar catalogo"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [Text("Preencha todos os campos!")],
              ),
            );
          });
    } else {
      String? imageUrl =
          await uploadImages(imageProduct, nameProduct, uidCatalog, false);

      String uid = RandomKeys().generateRandomString();

      DBProductModel dbProductModel = DBProductModel();

      dbProductModel.uid = uid;
      dbProductModel.nameProduct = nameProduct;
      dbProductModel.descriptionProduct = descriptionProduct;
      dbProductModel.priceProduct = priceProduct;
      dbProductModel.quantityProduct = quantityProduct;
      dbProductModel.imageProduct = imageUrl!;

      await firestore
          .collection("Catalogos")
          .doc(uidCatalog)
          .collection("Produtos")
          .doc(uid)
          .set(dbProductModel.toMap(uid))
          .then((value) => Navigator.pop(context));
    }
  }

  static Future<void> editProduct(
      BuildContext context,
      String uidCatalog,
      String uidProduct,
      String nameProduct,
      String descriptionProduct,
      String priceProduct,
      String quantityProduct,
      String imageProduct) async {
    if (nameProduct == "" ||
        descriptionProduct == "" ||
        imageProduct == "" ||
        quantityProduct == "" ||
        priceProduct == "") {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Erro ao editar produto"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [Text("Preencha todos os campos!")],
              ),
            );
          });
    } else {
      bool isNetworkImage(String path) {
        return path.startsWith('http://') || path.startsWith('https://');
      }

      String? imageUrl = isNetworkImage(imageProduct)
          ? imageProduct
          : await uploadImages(imageProduct, nameProduct, uidCatalog, true);

      await firestore
          .collection("Catalogos")
          .doc(uidCatalog)
          .collection("Produtos")
          .doc(uidProduct)
          .update({
        "nome": nameProduct,
        "descricao": descriptionProduct,
        "preco": priceProduct,
        "quantidade": quantityProduct,
        "imagem": imageUrl,
      }).then((value) => Navigator.pop(context));
    }
  }

  static Future<String?> uploadImages(
      String picker, String title, String uidCatalog, bool edit) async {
    if (picker == "Sem Imagem") {
      debugPrint("Sem Imagem");
      return null;
    } else {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference raiz = storage.ref();

      Reference file = raiz
          .child("Catalogos")
          .child(uidCatalog)
          .child("Produtos")
          .child(title)
          .child("$title.png");

      UploadTask uploadTask = file.putFile(File(picker));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    }
  }
}
