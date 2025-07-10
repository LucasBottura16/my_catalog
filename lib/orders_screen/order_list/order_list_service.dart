import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static Future<Stream<QuerySnapshot>?>? addListenerOrder(
      StreamController<QuerySnapshot> controllerStream) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String typeAccount = prefs.getString('typeAccount') ?? '';

    Stream<QuerySnapshot> stream = firestore
        .collection("Pedidos")
        .where(typeAccount == "company" ? "uidComapny" : "uidCustomer",
            isEqualTo: prefs.getString('uid')).orderBy("orderDate", descending: true).orderBy("status", descending: true)
        .snapshots();

    stream.listen((event) {
      controllerStream.add(event);
    });

    return null;
  }
}
