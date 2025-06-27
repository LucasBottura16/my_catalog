import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {

  static Future<void> logoutUser(context)async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut().then((value) =>
        Navigator.pushNamedAndRemoveUntil(
            context, RouteGenerator.routeLogin, (_) => false));
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