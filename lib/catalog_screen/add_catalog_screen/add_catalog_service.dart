import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      dbAddCatalog.nameCompany = prefs.getString('name')!;

      await firestore
          .collection("Catalogos")
          .doc(uid)
          .set(dbAddCatalog.toMapCatalog(uid, prefs.getString('uid') ?? ''))
          .then((value) => Navigator.pop(context));
    }

  }

  static Future<String?> uploadImages(
      String picker, String title, String uid) async {
    if (picker == "Sem Imagem" || picker.isEmpty) {
      debugPrint("Sem Imagem");
      return null;
    }

    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference raiz = storage.ref();
      final Reference file = raiz
          .child("Catalogos")
          .child(uid)
          .child("$title.png");

      if (kIsWeb) {
        final XFile image = XFile(picker);
        final bytes = await image.readAsBytes();
        final UploadTask uploadTask = file.putData(bytes);
        final TaskSnapshot taskSnapshot = await uploadTask;
        return await taskSnapshot.ref.getDownloadURL();
      } else {
        final File imageFile = File(picker);
        final UploadTask uploadTask = file.putFile(imageFile);
        final TaskSnapshot taskSnapshot = await uploadTask;
        return await taskSnapshot.ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint("Erro ao fazer upload da imagem: $e");
      return null;
    }
  }

}