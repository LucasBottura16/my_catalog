import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      dynamic picker,
      String title,
      String uidCatalog,
      bool edit,
      ) async {
    // Caso não tenha imagem selecionada
    if (picker == null || picker == "Sem Imagem" || (picker is String && picker.isEmpty)) {
      debugPrint("Sem Imagem");
      return null;
    }

    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference raiz = storage.ref();

      // Construindo o caminho do arquivo no Storage
      Reference fileRef = raiz.child("Catalogos").child(uidCatalog).child("Produtos");

      // Se for edição, mantemos a mesma estrutura de pastas
      if (edit) {
        fileRef = fileRef.child(title).child("$title.png");
      } else {
        // Para novos uploads, podemos adicionar um timestamp para evitar conflitos
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileRef = fileRef.child("${title}_$timestamp").child("$title.png");
      }

      // Upload para Firebase Storage
      if (kIsWeb) {
        // Para web - pode receber XFile ou path temporário
        final XFile image = picker is XFile ? picker : XFile(picker);
        final bytes = await image.readAsBytes();
        await fileRef.putData(bytes);
      } else {
        // Para mobile - pode receber File ou path
        final File imageFile = picker is File ? picker : File(picker.toString());
        await fileRef.putFile(imageFile);
      }

      // Retorna a URL de download
      return await fileRef.getDownloadURL();

    } catch (e) {
      debugPrint("Erro ao fazer upload da imagem: $e");
      return null;
    }
  }
}
