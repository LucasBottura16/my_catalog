import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/profile_screen/profile_service.dart';
import 'package:my_catalog/profile_screen/profile_style.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:my_catalog/utils/customs_components/custom_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _controllerStream = StreamController<QuerySnapshot>.broadcast();

  final TextEditingController _controllerBiography = TextEditingController();
  String _nome = "";
  String _state = "";
  String _category = "";
  String _photo = "";
  String _biography = "";
  String _typeAccount = "";

  @override
  void initState() {
    super.initState();
    _verifyAccount();
    ProfileService.addListenerCatalog(_controllerStream);
  }

  @override
  void dispose() {
    _controllerStream.close();
    _controllerBiography.dispose();
    super.dispose();
  }

  _verifyAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nome = prefs.getString('name') ?? '';
      _photo = prefs.getString('image') ?? '';
      _state = prefs.getString('state') ?? '';
      _category = prefs.getString('category') ?? '';
      _biography = prefs.getString('biography') ?? '';
      _typeAccount = prefs.getString('typeAccount') ?? '';
    });
    _controllerBiography.text = _biography;
  }

  _saveBiography() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_controllerBiography.text.trim().isEmpty) {
      debugPrint("biografia vazia");
      setState(() {
        _biography = prefs.getString('biography') ?? '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A biografia não pode ser vazia.')),
      );
    } else {
      debugPrint("biografia salva");
      await ProfileService.saveBiography(_controllerBiography.text);
      prefs.setString('biography', _controllerBiography.text);
      setState(() {
        _biography = _controllerBiography.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        width: 120,
                        height: 120,
                        color: MyColors.myPrimary,
                        child: _photo.isEmpty
                            ? Image.asset(
                                "images/Logo.png",
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                _photo,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                      'Erro ao carregar imagem de perfil: $error');
                                  return Image.asset(
                                    "images/Logo.png",
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_nome,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("$_state - $_category",
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 35),
                        GestureDetector(
                          onTap: () {
                            ProfileService.logoutUser(context);
                          },
                          child: const Text("logout",
                              style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Biografia",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_biography.isEmpty ||
                            _controllerBiography.text.isNotEmpty) {
                          _saveBiography(); // Salva a biografia se o TextField está visível e preenchido
                        } else {
                          setState(() {
                            _biography = ""; // Faz o TextField aparecer
                          });
                        }
                      },
                      child: Text(
                        _biography.isEmpty ? "Salvar" : "Editar",
                        style: const TextStyle(color: MyColors.myPrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 80,
                  child: _biography.isEmpty
                      ? TextField(
                          decoration: const InputDecoration(
                              hintText: "Descreva sua Biografia"),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          controller: _controllerBiography,
                        )
                      : Text(_biography),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: profileButtonStyle,
                      onPressed: () async {
                        Navigator.pushNamed(context, RouteGenerator.orderView);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "PEDIDOS",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            size: 30,
                            weight: 3.5,
                            color: Colors.white,
                          )
                        ],
                      )),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: MyColors.myPrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            _typeAccount == "company"
                                ? "Meus Catálogos"
                                : "Catálogos Salvos",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),

                        CustomButton(onPressed: (){}, title: "+",
                            titleSize: 20,
                            titleColor: MyColors.myPrimary,
                            buttonEdgeInsets: const EdgeInsets.only(
                               left: 20),
                        ),
                      ],
                    )
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _controllerStream.stream,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Carregando Catálogos...",
                                      style: TextStyle(color: Colors.white)),
                                  SizedBox(height: 10),
                                  CircularProgressIndicator(
                                      color: Colors.white),
                                ],
                              ),
                            );
                          case ConnectionState.active:
                          case ConnectionState.done:
                            if (snapshot.hasError) {
                              debugPrint(
                                  "Erro no StreamBuilder de Catálogos: ${snapshot.error}");
                              return Center(
                                child: Text(
                                    "Erro ao carregar catálogos: ${snapshot.error}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red)),
                              );
                            }

                            QuerySnapshot? querySnapshot = snapshot.data;

                            if (querySnapshot == null ||
                                querySnapshot.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  "Nenhum catálogo encontrado!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              );
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot documentSnapshot =
                                    querySnapshot.docs[index];
                                DBAddCatalog myCatalog =
                                    DBAddCatalog.fromDocumentSnapshotCatalog(
                                        documentSnapshot);

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: SizedBox(
                                    width: 340,
                                    child: CustomCatalog(
                                      title: myCatalog.catalogName,
                                      imageUrl: myCatalog.catalogImage,
                                      textButton: "Editar",
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          RouteGenerator.productCatalog,
                                          arguments: {
                                            'catalog': myCatalog,
                                            'isEditing': true,
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _typeAccount == "company"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteGenerator.addCatalog);
              },
              tooltip: 'Adicionar',
              backgroundColor: MyColors.myPrimary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
