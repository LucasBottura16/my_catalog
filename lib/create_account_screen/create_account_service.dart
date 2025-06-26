import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/create_account_screen/models/create_account_model.dart';
import 'package:my_catalog/route_generator.dart';

class CreateAccountService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static List<String> listStates() {
    List<String> states = [
      'Acre',
      'Alagoas',
      'Amapá',
      'Amazonas',
      'Bahia',
      'Ceará',
      'Distrito Federal',
      'Espírito Santo',
      'Goiás',
      'Maranhão',
      'Mato Grosso',
      'Mato Grosso do Sul',
      'Minas Gerais',
      'Pará',
      'Paraíba',
      'Paraná',
      'Pernambuco',
      'Piauí',
      'Rio de Janeiro',
      'Rio Grande do Norte',
      'Rio Grande do Sul',
      'Rondônia',
      'Roraima',
      'Santa Catarina',
      'São Paulo',
      'Sergipe',
      'Tocantins',
    ];
    return states;
  }

  static Future<void> createAccount(
    BuildContext context,
    String typeAccount,
    String name,
    String cpf,
    String state,
    String address,
    String phone,
    String company,
    String cnpj,
    String representative,
    String category,
    String email,
    String password,
  ) async {
    String verify = await verifyFields(
        context,
        typeAccount,
        name,
        cpf,
        state,
        address,
        phone,
        company,
        cnpj,
        representative,
        category,
        email,
        password);

    if (verify == "error") return;

    await auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => completedRegister(
                value.user!.uid,
                typeAccount,
                name,
                cpf,
                state,
                address,
                phone,
                company,
                cnpj,
                representative,
                category)
            .then((value) => Navigator.pushNamedAndRemoveUntil(
                context, RouteGenerator.routeLogin, (_) => false))
            .then((value) => Navigator.pop(context)));
  }

  static Future<void> completedRegister(
    String uid,
    String typeAccount,
    String name,
    String cpf,
    String state,
    String address,
    String phone,
    String company,
    String cnpj,
    String representative,
    String category,
  ) async {
    switch (typeAccount) {
      case 'Empresa':
        final DBCreateCompany dbCreateCompany = DBCreateCompany();

        dbCreateCompany.companyName = company;
        dbCreateCompany.cnpj = cnpj;
        dbCreateCompany.representative = representative;
        dbCreateCompany.category = category;
        dbCreateCompany.state = state;
        dbCreateCompany.address = address;
        dbCreateCompany.phone = phone;

        await firestore
            .collection("Users")
            .doc("companies")
            .collection("allCompanies")
            .doc(uid)
            .set(dbCreateCompany.toMap(uid))
            .then((value) => debugPrint("Empresa criada com sucesso!"));
        break;

      case 'Cliente':
        final DBCreateCustomer dbCreateCustomer = DBCreateCustomer();

        dbCreateCustomer.name = name;
        dbCreateCustomer.cpf = cpf;
        dbCreateCustomer.state = state;
        dbCreateCustomer.address = address;
        dbCreateCustomer.phone = phone;

        await firestore
            .collection("Users")
            .doc("customers")
            .collection("allCustomers")
            .doc(uid)
            .set(dbCreateCustomer.toMap(uid))
            .then((value) => debugPrint("Cliente criado com sucesso!"));
        break;
    }
  }

  static verifyFields(
      BuildContext context,
      String typeAccount,
      String name,
      String cpf,
      String state,
      String address,
      String phone,
      String company,
      String cnpj,
      String representative,
      String category,
      String email,
      String password) {
    if (typeAccount == "Cliente") {
      if (name == "" ||
          cpf == "" ||
          state == "" ||
          address == "" ||
          phone == "" ||
          email == "" ||
          password == "") {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Erro ao criar conta"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "Preencha todos os campos para criar sua conta do cliente!")
                  ],
                ),
              );
            });
        return "error";
      }
      return "success";
    } else if (typeAccount == "Empresa") {
      if (state == "" ||
          address == "" ||
          phone == "" ||
          company == "" ||
          cnpj == "" ||
          representative == "" ||
          category == "" ||
          email == "" ||
          password == "") {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Erro ao criar conta"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "Preencha todos os campos para criar sua conta da empresa!")
                  ],
                ),
              );
            });
        return "error";
      }
      return "success";
    }
  }
}
