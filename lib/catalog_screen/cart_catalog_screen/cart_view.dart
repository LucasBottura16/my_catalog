import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/cart_catalog_screen/cart_service.dart';
import 'package:my_catalog/catalog_screen/cart_catalog_screen/components/cart_manager.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (CartManager.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seu carrinho está vazio!')),
      );
      return;
    }

    if(_catalog.uidCompany == prefs.getString('uid')){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você não pode fazer pedidos para sua própria empresa!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cartItems =
        CartManager.items;

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seu carrinho está vazio!')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    await CartService.addOrder(
        context: context,
        catalog: _catalog,
        cartItems: cartItems);

    _onCartChanged();

    setState(() {
      _isLoading = false;
    });
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
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Carrinho de pedidos ${_catalog.nameCompany}:",
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
                SizedBox(
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
                _isLoading ? SizedBox(height: 30) : const SizedBox(),
              ],
            ),
    );
  }
}
