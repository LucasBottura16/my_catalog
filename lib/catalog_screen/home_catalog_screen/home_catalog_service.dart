import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeCatalogService {

  static Future<Stream<QuerySnapshot>?>? addListenerCatalog(
      StreamController<QuerySnapshot> controllerStream) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Stream<QuerySnapshot> stream = firestore
        .collection("Catalogos")
        .snapshots();

    stream.listen((event) {
      controllerStream.add(event);
    });

    return null;
  }

}