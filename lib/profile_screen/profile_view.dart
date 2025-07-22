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
    debugPrint(_biography);
  }

  _saveBiography() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_controllerBiography.text
        .trim()
        .isEmpty) {
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

  _deleteCatalog(String catalogId) async {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text("Excluir Catálogo"),
              content: const Text(
                  "Você tem certeza que deseja excluir este catálogo?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () async {
                    await ProfileService.deleteCatalog(catalogId);
                    Navigator.pop(context);
                  },
                  child: const Text("Excluir",
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    // Define uma largura máxima para o conteúdo principal em telas grandes (Web)
    final double contentMaxWidth = screenWidth > 1000 ? 1000 : screenWidth;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column( // Esta Column é a principal e conterá os dois blocos
          children: [
            // Bloco 1: Conteúdo do perfil (limitado a contentMaxWidth)
            Center( // Centraliza o conteúdo horizontalmente na web
              child: ConstrainedBox( // Limita a largura do conteúdo principal
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(20), // Padding aplicado aqui
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seção de Imagem de Perfil e Info do Usuário
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              width: 100,
                              height: 100,
                              color: MyColors.myPrimary,
                              child: _photo.isEmpty
                                  ? Image.asset(
                                "images/Logo.png",
                                fit: BoxFit.cover,
                              )
                                  : Image.network(
                                _photo,
                                width: 100,
                                height: 100,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nome,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "$_state - $_category",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 15),
                                GestureDetector(
                                  onTap: () {
                                    ProfileService.logoutUser(context);
                                  },
                                  child: const Text("Sair",
                                      style: TextStyle(color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Seção de Biografia
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Biografia",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              _biography.isEmpty
                                  ? _saveBiography()
                                  : setState(() {
                                _biography = "";
                                _controllerBiography.text = "";
                              });
                            },
                            child: Text(
                              _biography.isEmpty ? "Salvar" : "Editar",
                              style: const TextStyle(color: MyColors.myPrimary),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        constraints: BoxConstraints(
                            maxHeight: _biography.isEmpty ? 150 : double
                                .infinity),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: _biography.isEmpty
                            ? BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        )
                            : null,
                        child: _biography.isEmpty
                            ? TextField(
                          decoration: const InputDecoration(
                            hintText: "Descreva sua Biografia",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          maxLines: null,
                          minLines: 3,
                          keyboardType: TextInputType.multiline,
                          controller: _controllerBiography,
                          textAlignVertical: TextAlignVertical.top,
                        )
                            : Text(
                          _biography,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Botão de Pedidos
                      SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: ElevatedButton(
                            style: profileButtonStyle,
                            onPressed: () async {
                              Navigator.pushNamed(
                                  context, RouteGenerator.orderView);
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
                                  color: Colors.white,
                                )
                              ],
                            )),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Bloco 2: Seção de Catálogos (ocupa a tela toda)
            // *** ALTERAÇÃO AQUI: MOVIDO PARA FORA DO ConstrainedBox PRINCIPAL ***
            Container(
              color: MyColors.myPrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              // Não precisa mais do 'width: MediaQuery.of(context).size.width' aqui,
              // 'double.infinity' já fará ele ocupar toda a largura disponível
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            _typeAccount == "company"
                                ? "Meus Catálogos"
                                : "Catálogos Salvos",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                        _typeAccount == "company"
                            ? CustomButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RouteGenerator.addCatalog);
                          },
                          title: "+",
                          titleSize: 20,
                          titleColor: MyColors.myPrimary,
                          buttonColor: Colors.white,
                          buttonEdgeInsets: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          buttonBorderRadius: 8,
                        )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
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
                                  "Erro no StreamBuilder de Catálogos: ${snapshot
                                      .error}");
                              return Center(
                                child: Text(
                                    "Erro ao carregar catálogos: ${snapshot
                                        .error}",
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
                                  padding: const EdgeInsets.only(right: 15),
                                  child: SizedBox(
                                      width: 300,
                                      child: GestureDetector(
                                        onLongPress: () {
                                          _deleteCatalog(myCatalog.uid);
                                        },
                                        child: CustomCatalog(
                                          title: myCatalog.catalogName,
                                          imageUrl: myCatalog.catalogImage,
                                          textButton: "Editar",
                                          isCompactMode: true,
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
                                      )),
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
          ],
        ),
      ),
    );
  }
}
