import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CartService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> updateProductQuantityAfterOrder({
    required String catalogId,
    required String productId,
    required int orderedQuantity,
  }) async {
    try {
      final DocumentReference productRef = _firestore
          .collection('Catalogos')
          .doc(catalogId)
          .collection('Produtos')
          .doc(productId);

      final DocumentSnapshot productDoc = await productRef.get();

      if (!productDoc.exists) {
        debugPrint('Erro: Produto com ID $productId não encontrado no catálogo $catalogId.');
        return;
      }

      final String currentQuantityString = productDoc.get('quantidade') as String;
      int currentQuantity = int.tryParse(currentQuantityString) ?? 0;

      int newQuantity = currentQuantity - orderedQuantity;

      if (newQuantity < 0) {
        debugPrint(
            'Aviso: Tentando subtrair mais do que o estoque disponível para o produto $productId. Estoque ajustado para 0.');
        newQuantity = 0;
      }

      await productRef.update({
        'quantidade': newQuantity.toString(), // Store back as a String
      });

      debugPrint(
          'Quantidade do produto $productId (Catálogo: $catalogId) atualizada de $currentQuantity para $newQuantity.');
    } catch (e) {
      debugPrint('Erro ao atualizar a quantidade do produto no Firestore: $e');
    }
  }
}