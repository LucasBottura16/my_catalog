import 'package:my_catalog/catalog_screen/models/product_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';


class CartItem {
  final DBProductModel product;
  int quantity;
  String totalPriceFormatted;

  CartItem({
    required this.product,
    required this.quantity,
    required this.totalPriceFormatted,
  });
}

class CartManager {
  // **A principal mudança: _items agora é um ValueNotifier**
  static final ValueNotifier<List<CartItem>> _itemsNotifier = ValueNotifier([]);

  // **Novo Getter para expor o ValueNotifier para que os widgets possam ouvi-lo**
  static ValueNotifier<List<CartItem>> get itemsNotifier => _itemsNotifier;

  // Getter para acessar os itens (retorna uma cópia para proteger a lista original)
  // Agora ele acessa a lista através de _itemsNotifier.value
  static List<CartItem> get items => List.unmodifiable(_itemsNotifier.value);

  // Getter para o número de itens distintos no carrinho
  // Agora ele acessa a lista através de _itemsNotifier.value
  static int get itemCount => _itemsNotifier.value.length;

  // Calcula o preço total do carrinho
  static double get totalCartPrice {
    double total = 0.0;
    // Percorre a lista atual do ValueNotifier
    for (var item in _itemsNotifier.value) {
      String cleanedPriceString = item.totalPriceFormatted
          .replaceAll('R\$', '')
          .trim()
          .replaceAll('.', '')
          .replaceAll(',', '.');
      try {
        total += double.parse(cleanedPriceString);
      } catch (e) {
        debugPrint('Erro ao parsear preço do item do carrinho: ${item.totalPriceFormatted} - $e');
      }
    }
    return total;
  }

  // Retorna o preço total do carrinho formatado
  static String get totalCartPriceFormatted {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return currencyFormatter.format(totalCartPrice);
  }

  // Adiciona um produto ao carrinho
  static void addProduct(DBProductModel product, int quantity, String totalPriceFormatted) {
    // **Sempre trabalhe em uma cópia da lista e depois atribua de volta ao ValueNotifier**
    List<CartItem> currentItems = List.from(_itemsNotifier.value);

    int existingIndex = currentItems.indexWhere((item) => item.product.uid == product.uid);

    if (existingIndex != -1) {
      // Atualiza a quantidade diretamente (substitui a antiga pela nova)
      currentItems[existingIndex].quantity = quantity;
      currentItems[existingIndex].totalPriceFormatted = _calculateTotalPriceString(
        currentItems[existingIndex].product.priceProduct,
        currentItems[existingIndex].quantity.toString(),
      );
      debugPrint('Produto "${product.nameProduct}" (UID: ${product.uid}) QUANTIDADE ATUALIZADA para $quantity.');
    } else {
      // Adiciona como um novo item
      currentItems.add(CartItem(
        product: product,
        quantity: quantity,
        totalPriceFormatted: totalPriceFormatted,
      ));
      debugPrint('Produto "${product.nameProduct}" (UID: ${product.uid}) ADICIONADO ao carrinho com quantidade $quantity.');
    }
    // **MUITO IMPORTANTE: Atribua a nova lista para notificar os ouvintes**
    _itemsNotifier.value = currentItems;
  }

  // Remove um produto do carrinho
  static void removeProduct(String productId) {
    List<CartItem> currentItems = List.from(_itemsNotifier.value);
    currentItems.removeWhere((item) => item.product.uid == productId); // Use uid para comparação
    _itemsNotifier.value = currentItems; // Notifica os ouvintes
    debugPrint('Item removido. Total de itens: ${_itemsNotifier.value.length}');
  }

  // Limpa o carrinho
  static void clearCart() {
    _itemsNotifier.value = []; // Atribui uma lista vazia para notificar os ouvintes
    debugPrint('Carrinho limpo.');
  }

  // Função auxiliar para calcular o preço total (permanece a mesma)
  static String _calculateTotalPriceString(String priceString, String quantityString) {
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

    int quantity;
    try {
      quantity = int.parse(quantityString);
    } catch (e) {
      debugPrint("Erro ao converter a quantidade '$quantityString': $e");
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
}