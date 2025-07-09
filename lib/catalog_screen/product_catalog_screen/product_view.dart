import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/product_catalog_screen/components/cart_manager.dart';
import 'package:my_catalog/catalog_screen/product_catalog_screen/components/detail_product.dart';
import 'package:my_catalog/catalog_screen/product_catalog_screen/components/product_modal.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/catalog_screen/models/product_model.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:my_catalog/utils/customs_components/custom_input_field.dart';
import 'product_service.dart';

class ProductView extends StatefulWidget {
  const ProductView(
      {super.key, required this.catalog, required this.isEditing});

  final DBAddCatalog catalog;
  final bool isEditing;

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  late final DBAddCatalog _catalog;
  late final bool _isEditing;

  final _controllerStream = StreamController<QuerySnapshot>.broadcast();

  void _addProductsModal(DBProductModel? product) async {

    if (_isEditing) {
      await showDialog(
          context: context,
          builder: (context) {
            return ProductModal(
              catalog: _catalog,
              editCatalog: product,
            );
          });
    } else {
      if (product == null && !_isEditing) {
        Navigator.pushNamed(
          context,
          RouteGenerator.cartView,
        );
      } else {
        await showDialog(
            context: context,
            builder: (context) {
              return DetailsProductModal(product: product);
            });
        setState(() {});
      }
    }
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog;
    _isEditing = widget.isEditing;
    CartManager.clearCart();
    ProductService.addListenerProducts(_controllerStream, _catalog.uid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCartPriceFormatted = CartManager.totalCartPriceFormatted;

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
        actions: [
          Image.asset("images/Logo.png", width: 70, height: 70), // Sua logo
        ],
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
                    icon: const Icon(
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

                        return ValueListenableBuilder<List<CartItem>>(
                          valueListenable: CartManager.itemsNotifier,
                          builder: (context, currentCartItems, child) {
                            CartItem? cartItem =
                                currentCartItems.firstWhereOrNull((item) =>
                                    item.product.uid == myProduct.uid);

                            int initialStock =
                                int.tryParse(myProduct.quantityProduct) ?? 0;
                            int quantityInCart = cartItem?.quantity ?? 0;
                            int remainingStock = initialStock - quantityInCart;

                            if (remainingStock < 0) {
                              remainingStock = 0;
                            }

                            String displayText = remainingStock.toString();
                            Color badgeColor = MyColors.myPrimary; // Cor padrão

                            if (remainingStock <= 0) {
                              displayText = "0";
                              badgeColor = Colors.grey;
                            }

                            return Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (remainingStock > 0 ||
                                                _isEditing) {
                                              _addProductsModal(myProduct);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Produto fora de estoque!')));
                                            }
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(12.0)),
                                            child: (myProduct.imageProduct !=
                                                        "Sem imagem" &&
                                                    myProduct.imageProduct
                                                        .isNotEmpty)
                                                ? Image.network(
                                                    myProduct.imageProduct,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
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
                                                    child: const Icon(
                                                        Icons.image,
                                                        size: 60,
                                                        color: Colors.grey),
                                                  ),
                                          ),
                                        ),
                                      ),
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
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          displayText,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 15,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 30),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                          child: Column(
                                        children: [
                                          Text(
                                            myProduct.nameProduct,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            myProduct.priceProduct,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                  _isEditing
                                      ? Positioned(
                                          top: 8,
                                          left: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              ProductService.deleteProduct(
                                                  context,
                                                  _catalog.uid,
                                                  myProduct.uid,
                                                  myProduct.nameProduct);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.delete,
                                                    color: Colors.white,
                                                    size: 18),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            );
                          },
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
                    _addProductsModal(
                        null);
                  },
                  title: _isEditing
                      ? "CADASTRAR PRODUTO"
                      : "MONTAR PEDIDO ($totalCartPriceFormatted)",
                  titleColor: Colors.white,
                  titleSize: 16,
                  buttonEdgeInsets:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                  buttonColor: MyColors.myPrimary,
                  buttonBorderRadius: 0,
                  icon: _isEditing ? null : Icons.shopping_cart,
                  iconColor: Colors.white,
                  iconSize: 30,
                )),
          ),
        ],
      ),
    );
  }
}

extension IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
