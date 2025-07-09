import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_catalog/catalog_screen/models/product_model.dart';
import 'package:my_catalog/catalog_screen/cart_catalog_screen/components/cart_manager.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:my_catalog/utils/customs_components/custom_counter.dart';

class DetailsProductModal extends StatefulWidget {
  const DetailsProductModal({super.key, this.product});

  final DBProductModel? product;

  @override
  State<DetailsProductModal> createState() => _DetailsProductModalState();
}

class _DetailsProductModalState extends State<DetailsProductModal> {
  late final DBProductModel _product;
  String? _newPrice;
  int _selectedQuantity = 1;

  String _calculateFormattedTotalPrice(String priceString, int quantity) {
    String cleanedPriceString = priceString
        .replaceAll('R\$', '')
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');

    double unitPrice;
    try {
      unitPrice = double.parse(cleanedPriceString);
    } catch (e) {
      debugPrint("Erro ao converter o preço unitário '$priceString': $e");
      return "R\$ 0,00";
    }

    if (quantity <= 0) {
      return "R\$ 0,00";
    }

    double totalPrice = unitPrice * quantity;

    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return currencyFormatter.format(totalPrice);
  }

  void _updateTotalPriceDisplay() {
    setState(() {
      _newPrice = _calculateFormattedTotalPrice(_product.priceProduct, _selectedQuantity);
    });
  }

  void _addProductToCart(BuildContext context) {

      final String itemTotalPrice = _calculateFormattedTotalPrice(_product.priceProduct, _selectedQuantity);

      CartManager.addProduct(
        _product,
        _selectedQuantity,
        itemTotalPrice,
      );

      Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _product = widget.product!;
    _updateTotalPriceDisplay();
  }

  @override
  Widget build(BuildContext context) {
    int maxStockQuantity = int.tryParse(_product.quantityProduct) ?? 0;

    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.backspace_rounded, size: 20),
                SizedBox(width: 10),
                Text(
                  "FECHAR",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                )
              ],
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _product.imageProduct,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Erro ao carregar imagem de rede: $error');
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.broken_image,
                            size: 30, color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(_product.nameProduct,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(_product.descriptionProduct, textAlign: TextAlign.justify),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuantityCounter(
                    initialQuantity: _selectedQuantity,
                    maxQuantity: maxStockQuantity,
                    onChanged: (newQuantity) {
                      setState(() {
                        _selectedQuantity = newQuantity;
                        _updateTotalPriceDisplay();
                      });
                    },
                  ),
                  Expanded(
                    child: CustomButton(
                      onPressed: () => _addProductToCart(context),
                      title: _newPrice!,
                      buttonColor: MyColors.myPrimary,
                      titleColor: Colors.white,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}