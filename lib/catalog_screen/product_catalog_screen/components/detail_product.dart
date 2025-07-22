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
      _newPrice = _calculateFormattedTotalPrice(
          _product.priceProduct, _selectedQuantity);
    });
  }

  void _addProductToCart(BuildContext context) {
    final String itemTotalPrice =
        _calculateFormattedTotalPrice(_product.priceProduct, _selectedQuantity);

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
    // Obtenha a largura da tela para decisões de responsividade
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define uma largura máxima para o modal na web
    final double maxModalWidth = screenWidth > 600
        ? 500
        : screenWidth * 0.9; // 500px ou 90% da largura da tela

    int maxStockQuantity = int.tryParse(_product.quantityProduct) ?? 0;

    return Dialog(
        // <--- Use Dialog em vez de AlertDialog para mais controle
        backgroundColor: Colors
            .transparent, // Torna o fundo transparente para o Material do Dialog
        insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20), // Padding nas laterais e vertical
        child: ConstrainedBox(
          // <--- Restringe a largura máxima do modal
          constraints: BoxConstraints(
            maxWidth: maxModalWidth,
          ),
          child: SingleChildScrollView(
            // <--- Mantém o SingleChildScrollView para rolagem interna
            child: Material(
              // <--- Material para o estilo do AlertDialog (fundo branco, arredondado)
              borderRadius: BorderRadius.circular(10), // Borda arredondada
              color: Colors.white, // Fundo branco
              child: Padding(
                // Adiciona padding geral ao conteúdo do modal
                padding: const EdgeInsets.all(16.0), // Padding interno
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Estende os filhos horizontalmente
                  mainAxisSize: MainAxisSize
                      .min, // A coluna ocupa o mínimo de espaço vertical necessário
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Align(
                        // <--- Alinha o botão de fechar à esquerda ou direita
                        alignment: Alignment
                            .centerLeft, // Ou Alignment.centerRight para o outro lado
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 10.0), // Espaçamento abaixo do botão
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // A Row ocupa o mínimo de espaço
                            children: [
                              Icon(Icons.arrow_back,
                                  size:
                                      20), // Ícone mais comum para "voltar/fechar"
                              SizedBox(width: 5), // Reduzido o espaço
                              Text(
                                "FECHAR",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16), // Ajustado tamanho
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Imagem do Produto
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _product.imageProduct,
                        // Removido width: MediaQuery.of(context).size.width
                        // A imagem agora vai tentar preencher a largura disponível do seu pai (Column)
                        // que é limitada pelo ConstrainedBox.
                        height: screenWidth * 0.6 > 300
                            ? 300
                            : screenWidth * 0.6, // Altura responsiva (max 300)
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Erro ao carregar imagem de rede: $error');
                          return Container(
                            // Ocupa a largura total disponível
                            height: screenWidth * 0.6 > 300
                                ? 300
                                : screenWidth *
                                    0.6, // Mesma altura do Image.network
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.broken_image,
                                  size: 40, color: Colors.grey[600]),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15), // Aumentado o espaço
                    // Nome do Produto
                    Text(
                      _product.nameProduct,
                      style: const TextStyle(
                        fontSize: 20, // Aumentado o tamanho da fonte
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduzido o espaço
                    // Descrição do Produto
                    Text(
                      _product.descriptionProduct,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                          fontSize: 14), // Tamanho da fonte para a descrição
                    ),
                    const SizedBox(height: 20), // Aumentado o espaço
                    // Contador de Quantidade e Botão de Adicionar ao Carrinho
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          CrossAxisAlignment.end, // Alinha os botões pela base
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
                        const SizedBox(
                            width: 10), // Espaço entre o contador e o botão
                        Expanded(
                          // <--- O CustomButton vai preencher o resto do espaço
                          child: CustomButton(
                            onPressed: () => _addProductToCart(context),
                            title: _newPrice!,
                            buttonColor: MyColors.myPrimary,
                            titleColor: Colors.white,
                            titleSize: 16, // Ajuste o tamanho da fonte do botão
                            buttonEdgeInsets: const EdgeInsets.symmetric(
                                vertical: 12), // Ajuste o padding do botão
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
