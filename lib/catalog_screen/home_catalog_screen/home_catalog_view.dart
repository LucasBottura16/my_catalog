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
    super.initState();
    HomeCatalogService.addListenerCatalog(_controllerStream);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final gridCrossAxisCount = isSmallScreen ? 1 : 3;
    final gridChildAspectRatio = isSmallScreen ? 0.8 : 1.0;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: 20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomInputField(
                        controller: _searchController,
                        labelText: "Sem texto",
                        hintText: "Buscar produto",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, size: 30),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
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
                              SizedBox(height: 16),
                              CircularProgressIndicator(color: Colors.white),
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

                        if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "Nenhum catálogo encontrado!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 24,
                            vertical: 8,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCrossAxisCount,
                            childAspectRatio: gridChildAspectRatio,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
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
                              textButton: "Acessar",
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteGenerator.productCatalog,
                                  arguments: {
                                    'catalog': myCatalog,
                                    'isEditing': false,
                                  },
                                );
                              },
                            );
                          },
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}