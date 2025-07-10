import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {

  static Future findCollectionByUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final String? email = FirebaseAuth.instance.currentUser!.email;

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      debugPrint('Procurando UID "$uid" na coleção "usuario"...');

      DocumentSnapshot customerDoc = await firestore.collection('Users').doc("customers")
          .collection('allCustomers').doc(uid).get();

      if (customerDoc.exists) {
        var customerDocs = customerDoc.data() as Map<String, dynamic>?;

        prefs.setString("typeAccount", "customer");
        prefs.setString("uid", customerDocs?["uid"]);
        prefs.setString("name", customerDocs?["nome"]);
        prefs.setString("cpf", customerDocs?["cpf"]);
        prefs.setString("state", customerDocs?["estado"]);
        prefs.setString("address", customerDocs?["endereco"]);
        prefs.setString("image", customerDocs?["imagem"]);
        prefs.setString("phone", customerDocs?["telefone"]);
        prefs.setString("biography", customerDocs?["biografia"]);
        prefs.setString("email", email.toString());

        return;
      }

      DocumentSnapshot companyDoc = await firestore.collection('Users').doc("companies")
          .collection("allCompanies").doc(uid).get();

      if (companyDoc.exists) {
        var companyDocs = companyDoc.data() as Map<String, dynamic>?;

        prefs.setString("typeAccount", "company");
        prefs.setString("uid", companyDocs?["uid"]);
        prefs.setString("name", companyDocs?["nome"]);
        prefs.setString("cnpj", companyDocs?["cnpj"]);
        prefs.setString("state", companyDocs?["estado"]);
        prefs.setString("address", companyDocs?["endereco"]);
        prefs.setString("image", companyDocs?["imagem"]);
        prefs.setString("phone", companyDocs?["telefone"]);
        prefs.setString("biography", companyDocs?["biografia"]);
        prefs.setString("category", companyDocs?["categoria"]);
        prefs.setString("representative", companyDocs?["representante"]);
        prefs.setString("email", email.toString());

        return;
      }

      debugPrint('UID "$uid" não encontrado nas coleções "usuario" e "empresa".');
      return null;

    } catch (e) {
      debugPrint('Erro ao procurar UID "$uid" nas coleções: $e');
      return null;
    }
  }
}