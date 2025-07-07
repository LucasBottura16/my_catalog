import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/utils/random_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCatalogService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> addCatalog(
      BuildContext context,
      String catalogName,
      String catalogDescription,
      String catalogImage,
      String catalogCategory,
      ) async {
    if (catalogName == "" || catalogDescription == "" || catalogImage == "" || catalogCategory == "") {
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

      String uid = RandomKeys().generateRandomString();

      String? imageUrl = await uploadImages(catalogImage, catalogName, uid);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      DBAddCatalog dbAddCatalog = DBAddCatalog();

      dbAddCatalog.uid = uid;
      dbAddCatalog.catalogName = catalogName;
      dbAddCatalog.catalogDescription = catalogDescription;
      dbAddCatalog.catalogImage = imageUrl!;
      dbAddCatalog.catalogCategory = catalogCategory;

      await firestore
          .collection("Catalogos")
          .doc(uid)
          .set(dbAddCatalog.toMapCatalog(uid, prefs.getString('uid') ?? ''))
          .then((value) => Navigator.pop(context));
    }

  }

  static Future<String?> uploadImages(
      String picker, String title, String uid) async {
    if (picker == "Sem Imagem") {
      debugPrint("Sem Imagem");
      return null;
    } else {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference raiz = storage.ref();
      Reference file = raiz
          .child("Catalogos")
          .child(uid)
          .child("$title.png");

      UploadTask uploadTask = file.putFile(File(picker));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    }
  }

}