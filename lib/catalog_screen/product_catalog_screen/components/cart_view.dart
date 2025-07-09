import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/product_catalog_screen/components/cart_manager.dart';
import 'package:my_catalog/utils/colors.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {

  void _onCartChanged() {
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();

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
              CartManager.clearCart();
              _onCartChanged(); // Força a reconstrução para atualizar a UI
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
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Seu carrinho está vazio.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                child: const Icon(Icons.broken_image, size: 30),
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
                              Text('Preço Unitário: ${cartItem.product.priceProduct}'),
                              Text(
                                'Subtotal: ${cartItem.totalPriceFormatted}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_shopping_cart, color: Colors.red),
                          onPressed: () {
                            CartManager.removeProduct(cartItem.product.uid);
                            _onCartChanged(); // Força a reconstrução
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('"${cartItem.product.nameProduct}" removido.')),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Total do Carrinho: $totalCartPriceFormatted",
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: MyColors.myPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Finalizar Compra Clicado!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.myPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Finalizar Compra",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}