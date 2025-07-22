import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/home_catalog_screen/home_catalog_service.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:my_catalog/utils/colors.dart';
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
  void dispose() {
    _controllerStream.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;

    // Responsive grid configuration
    final int gridCrossAxisCount;
    final double gridChildAspectRatio;
    final double horizontalPadding;
    final double verticalPadding;
    final double gridSpacing;

    if (isMobile) {
      gridCrossAxisCount = 1;
      gridChildAspectRatio = 2.3;
      horizontalPadding = 16.0;
      verticalPadding = 8.0;
      gridSpacing = 12.0;
    } else if (isTablet) {
      gridCrossAxisCount = 2;
      gridChildAspectRatio = 1.3;
      horizontalPadding = 20.0;
      verticalPadding = 12.0;
      gridSpacing = 16.0;
    } else {
      gridCrossAxisCount = 3;
      gridChildAspectRatio = 1.3;
      horizontalPadding = 24.0;
      verticalPadding = 16.0;
      gridSpacing = 20.0;
    }

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200.0),
          child: Column(
            children: [
              // Search and Filter Row
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20.0,
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
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, size: 30.0),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ],
                ),
              ),

              // Catalog Grid
               Expanded(child: StreamBuilder<QuerySnapshot>(
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
                                  style: TextStyle(color: MyColors.myPrimary)),
                              SizedBox(height: 16.0),
                              CircularProgressIndicator(
                                  color: MyColors.myPrimary),
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
                                style: TextStyle(color: MyColors.myPrimary)),
                          );
                        }

                        final QuerySnapshot? querySnapshot = snapshot.data;

                        if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                "Nenhum catálogo encontrado!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.myPrimary),
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCrossAxisCount,
                            childAspectRatio: gridChildAspectRatio,
                            crossAxisSpacing: gridSpacing,
                            mainAxisSpacing: gridSpacing,
                          ),
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                            querySnapshot.docs[index];
                            final DBAddCatalog myCatalog =
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