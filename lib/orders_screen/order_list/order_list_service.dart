import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static Future<Stream<QuerySnapshot>?>? addListenerOrderCustomer(
      StreamController<QuerySnapshot> controllerStream) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Stream<QuerySnapshot> stream = firestore
        .collection("Pedidos")
        .where("uidCustomer", isEqualTo: prefs.getString('uid'))
        .snapshots();

    stream.listen((event) {
      controllerStream.add(event);
    });

    return null;
  }

  static Future<Stream<QuerySnapshot>?>? addListenerOrderCompany(
      StreamController<QuerySnapshot> controllerStream) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Stream<QuerySnapshot> stream = firestore
        .collection("Pedidos")
        .where("uidComapny", isEqualTo: prefs.getString('uid'))
        .snapshots();

    stream.listen((event) {
      controllerStream.add(event);
    });

    return null;
  }

  static Stream<QuerySnapshot> getOrderCustomerStream(String uid) {
    return FirebaseFirestore.instance.collection("pedidos")
        .where("uidCustomer", isEqualTo: uid)
        .orderBy("orderDate", descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getOrderCompanyStream(String uid) {
    return FirebaseFirestore.instance.collection("pedidos")
        .where("uidCompany", isEqualTo: uid)
        .orderBy("orderDate", descending: true)
        .snapshots();
  }
}
