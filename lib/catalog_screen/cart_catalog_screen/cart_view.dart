import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/cart_catalog_screen/cart_service.dart';
import 'package:my_catalog/catalog_screen/cart_catalog_screen/components/cart_manager.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartView extends StatefulWidget {
  const CartView({super.key, required this.catalog});

  final DBAddCatalog catalog;

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late final DBAddCatalog _catalog;

  bool _isLoading = false;

  void _onCartChanged() {
    setState(() {});
  }

  Future<void> _placeOrder(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final cartItems =
        CartManager.items; // Get cart items directly from CartManager

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seu carrinho está vazio!')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      List<Map<String, dynamic>> productsData = [];
      for (var item in cartItems) {
        productsData.add({
          'productId': item.product.uid, // The UID of the product
          'productName': item.product.nameProduct,
          'quantity': item.quantity,
          'unitPrice': item.product.priceProduct,
          'totalItemPrice': item.totalPriceFormatted,
        });
      }

      Map<String, dynamic> orderData = {
        'orderDate': Timestamp.now(),
        'totalAmount': CartManager.totalCartPriceFormatted,
        'products': productsData,
        'status': 'Pendente',
        'uidCustomer': FirebaseAuth.instance.currentUser?.uid,
        'uidComapny': _catalog.uidCompany,
        'uidCatalog': _catalog.uid, // Catalog ID for the order
      };

      await firestore.collection('Pedidos').add(orderData);
      for (var item in cartItems) {
        await CartService.updateProductQuantityAfterOrder(
          catalogId: _catalog.uid,
          productId: item.product.uid,
          orderedQuantity: item.quantity,
        );
      }

      CartManager.clearCart();
      _onCartChanged(); // Force UI rebuild of the cart

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Pedido realizado com sucesso e estoque atualizado!')),
      );

      Navigator.pop(
          context);
    } catch (e) {
      debugPrint('Erro ao finalizar pedido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao finalizar pedido: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartManager.items;
    final totalCartPriceFormatted = CartManager.totalCartPriceFormatted;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Carrinho"),
        backgroundColor: MyColors.myPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              // Disable during loading
              CartManager.clearCart();
              _onCartChanged(); // Force rebuild to update UI
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Carrinho limpo!')),
              );
            },
            tooltip: 'Limpar Carrinho',
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Seu carrinho está vazio.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  // Added const
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Carrinho de pedidos:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cartItem.product.imageProduct,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image,
                                          size: 30),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.product.nameProduct,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Qtd: ${cartItem.quantity}'),
                                    Text(
                                        'Preço Unitário: ${cartItem.product.priceProduct}'),
                                    Text(
                                      'Subtotal: ${cartItem.totalPriceFormatted}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_shopping_cart,
                                    color: Colors.red),
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        // Disable during loading
                                        CartManager.removeProduct(
                                            cartItem.product.uid);
                                        _onCartChanged();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  '"${cartItem.product.nameProduct}" removido.')),
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: () =>
                            _placeOrder(context), // Call function here
                        title: "FINALIZAR PEDIDO ($totalCartPriceFormatted)",
                        titleColor: Colors.white,
                        titleSize: 16,
                        buttonEdgeInsets: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        buttonColor: MyColors.myPrimary,
                        buttonBorderRadius: 0,
                        isLoading: _isLoading,
                        loadingColor: MyColors.myPrimary,
                      )),
                ),
              ],
            ),
    );
  }
}
