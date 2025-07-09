import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/home_catalog_screen/home_catalog_service.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:my_catalog/utils/customs_components/custom_catalog.dart';
import 'package:my_catalog/utils/customs_components/custom_input_field.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final _controllerStream = StreamController<QuerySnapshot>.broadcast();

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HomeCatalogService.addListenerCatalog(_controllerStream);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomInputField(
                    controller: _searchController,
                    labelText: "Sem texto",
                    hintText: "buscar produto",
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.filter_list,
                      size: 30,
                    ))
              ],
            ),
          ),
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
                      return const Center(
                        child: Text("Erro ao carregar catálogos!",
                            style: TextStyle(color: Colors.white)),
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
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                        querySnapshot.docs[index];
                        DBAddCatalog myCatalog =
                        DBAddCatalog.fromDocumentSnapshotCatalog(
                            documentSnapshot);

                        return CustomCatalog(
                        title: myCatalog.catalogName,
                          imageUrl: myCatalog.catalogImage,
                        textButton:  "Acessar",
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RouteGenerator.productCatalog,
                              arguments: {
                                'catalog': myCatalog,
                                'isEditing': false,
                              },
                            );
                          },);
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
