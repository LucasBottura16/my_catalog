import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/product_catalog_screen/components/product_modal.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/catalog_screen/models/product_model.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:my_catalog/utils/customs_components/custom_input_field.dart';
import 'product_service.dart';

class ProductView extends StatefulWidget {
  const ProductView(
      {super.key, required this.catalog, required editCatalog});

  final DBAddCatalog catalog;

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  late final DBAddCatalog _catalog;

  final _controllerStream = StreamController<QuerySnapshot>.broadcast();

  void _addProductsModal(editCatalog) async {
    await showDialog(
        context: context,
        builder: (context) {
          return ProductModal(
            catalog: _catalog,
            editCatalog: editCatalog,
          );
        });
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog;
    ProductService.addListenerProducts(_controllerStream, _catalog.uid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.myPrimary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(_catalog.catalogName),
        actions: [Image.asset("images/Logo.png", width: 70, height: 70)],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(color: Colors.white38, boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ]),
            child: Text(
              _catalog.catalogDescription,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
          ),
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                              color: MyColors.myPrimary),
                          const SizedBox(height: 10),
                          Text("Carregando produtos...",
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      debugPrint(
                          "Erro no StreamBuilder de Produtos: ${snapshot.error}");
                      return Center(
                        child: Text(
                            "Erro ao carregar produtos: ${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[700])),
                      );
                    }

                    QuerySnapshot? querySnapshot = snapshot.data;

                    if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "Nenhum produto encontrado neste catálogo!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                            querySnapshot.docs[index];
                        DBProductModel myProduct =
                        DBProductModel.fromDocumentSnapshot(
                                documentSnapshot);

                        return Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _addProductsModal(myProduct);
                                      },
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12.0)),
                                        child: (myProduct.imageProduct !=
                                                    "Sem imagem" &&
                                                myProduct
                                                    .imageProduct.isNotEmpty)
                                            ? Image.network(
                                                myProduct.imageProduct,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                      color: Colors.grey),
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image,
                                                    size: 60,
                                                    color: Colors.grey),
                                              ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: MyColors.myPrimary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      myProduct.quantityProduct,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    ProductService.deleteProduct(
                                        context, _catalog.uid, myProduct.uid, myProduct.nameProduct);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.delete,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () {
                    _addProductsModal(null);
                  },
                  title: "CADASTRAR PRODUTO",
                  titleColor: Colors.white,
                  titleSize: 16,
                  buttonEdgeInsets: const EdgeInsets.symmetric(vertical: 25),
                  buttonColor: MyColors.myPrimary,
                  buttonBorderRadius: 0,
                )),
          ),
        ],
      ),
    );
  }
}
