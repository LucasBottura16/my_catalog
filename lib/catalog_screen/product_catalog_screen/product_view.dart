import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/cart_catalog_screen/components/cart_manager.dart';
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
  const ProductView({
    super.key,
    required this.catalog,
    required this.isEditing
  });

  final DBAddCatalog catalog;
  final bool isEditing;

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  late final DBAddCatalog _catalog;
  late final bool _isEditing;
  final _controllerStream = StreamController<QuerySnapshot>.broadcast();
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

  void _addProductsModal(DBProductModel? product) async {
    if (_isEditing) {
      await showDialog(
        context: context,
        builder: (context) => ProductModal(
          catalog: _catalog,
          editCatalog: product,
        ),
      );
    } else {
      if (product == null && !_isEditing) {
        Navigator.pushNamed(
            context,
            RouteGenerator.cartView,
            arguments: _catalog
        );
      } else {
        await showDialog(
          context: context,
          builder: (context) => DetailsProductModal(product: product),
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final gridCrossAxisCount = isSmallScreen ? 2 : 4;
    final totalCartPriceFormatted = CartManager.totalCartPriceFormatted;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.myPrimary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _catalog.catalogName,
          style: TextStyle(fontSize: isSmallScreen ? 18 : 22),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              "images/Logo.png",
              width: isSmallScreen ? 50 : 70,
              height: isSmallScreen ? 50 : 70,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Descrição do catálogo
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 40,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white38,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              _catalog.catalogDescription,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Barra de pesquisa
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 24,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    controller: _searchController,
                    labelText: "Sem texto",
                    hintText: "Buscar produto",
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(width: 8),
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

          // Lista de produtos
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
                          const SizedBox(height: 16),
                          Text(
                            "Carregando produtos...",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      debugPrint("Erro no StreamBuilder: ${snapshot.error}");
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Erro ao carregar produtos: ${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ),
                      );
                    }

                    QuerySnapshot? querySnapshot = snapshot.data;

                    if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Nenhum produto encontrado neste catálogo!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCrossAxisCount,
                        crossAxisSpacing: isSmallScreen ? 10 : 16,
                        mainAxisSpacing: isSmallScreen ? 10 : 16,
                        childAspectRatio: isSmallScreen ? 0.8 : 0.9,
                      ),
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = querySnapshot.docs[index];
                        DBProductModel product = DBProductModel.fromDocumentSnapshot(doc);

                        return ValueListenableBuilder<List<CartItem>>(
                          valueListenable: CartManager.itemsNotifier,
                          builder: (context, cartItems, child) {
                            CartItem? cartItem = cartItems.firstWhereOrNull(
                                    (item) => item.product.uid == product.uid);

                            int initialStock = int.tryParse(product.quantityProduct) ?? 0;
                            int quantityInCart = cartItem?.quantity ?? 0;
                            int remainingStock = initialStock - quantityInCart;
                            remainingStock = remainingStock < 0 ? 0 : remainingStock;

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  if (remainingStock > 0 || _isEditing) {
                                    _addProductsModal(product);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Produto fora de estoque!'),
                                      ),
                                    );
                                  }
                                },
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Imagem do produto
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                            child: (product.imageProduct != "Sem imagem" &&
                                                product.imageProduct.isNotEmpty)
                                                ? Image.network(
                                              product.imageProduct,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  _buildPlaceholderImage(),
                                            )
                                                : _buildPlaceholderImage(),
                                          ),
                                        ),

                                        // Nome e preço
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.nameProduct,
                                                style: TextStyle(
                                                  fontSize: isSmallScreen ? 14 : 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                product.priceProduct,
                                                style: TextStyle(
                                                  fontSize: isSmallScreen ? 13 : 15,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Badge de estoque
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: remainingStock > 0
                                              ? MyColors.myPrimary
                                              : Colors.grey,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          remainingStock.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Botão de deletar (modo edição)
                                    if (_isEditing)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: GestureDetector(
                                          onTap: () => ProductService.deleteProduct(
                                            context,
                                            _catalog.uid,
                                            product.uid,
                                            product.nameProduct,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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

          // Botão inferior
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: () => _addProductsModal(null),
              title: _isEditing
                  ? "CADASTRAR PRODUTO"
                  : "MONTAR PEDIDO ($totalCartPriceFormatted)",
              titleColor: Colors.white,
              titleSize: isSmallScreen ? 16 : 18,
              buttonEdgeInsets: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 18 : 20,
                horizontal: 16,
              ),
              buttonColor: MyColors.myPrimary,
              buttonBorderRadius: 0,
              icon: _isEditing ? null : Icons.shopping_cart,
              iconColor: Colors.white,
              iconSize: isSmallScreen ? 26 : 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
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