import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {

  static Future<void> deleteCatalog(String uid) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection("Catalogos")
        .doc(uid)
        .delete();
  }

  static Future<void> logoutUser(context)async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut().then((value) =>
        Navigator.pushNamedAndRemoveUntil(
            context, RouteGenerator.routeLogin, (_) => false));
  }

  static Future<Stream<QuerySnapshot>?>? addListenerCatalog(
      StreamController<QuerySnapshot> controllerStream) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Stream<QuerySnapshot> stream = firestore
        .collection("Catalogos")
    .where("uidEmpresa", isEqualTo: prefs.getString('uid'))
        .snapshots();

    stream.listen((event) {
      controllerStream.add(event);
    });

    return null;
  }

  static saveBiography(String biography) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String uid = prefs.getString('uid') ?? '';
    String typeAccount = prefs.getString('typeAccount') ?? '';

    if(typeAccount == 'customer'){
      await firestore.collection('Users').doc("customers")
          .collection('allCustomers').doc(uid).update({
        'biografia': biography,
      });
      prefs.setString("biography", biography);

    }else if(typeAccount == 'company'){
      await firestore.collection('Users').doc("companies")
          .collection('allCompanies').doc(uid).update({
        'biografia': biography,
      });
      prefs.setString("biography", biography);
    }
  }

}