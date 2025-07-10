import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/orders_screen/models/order_model.dart';

class OrderDetailsService {

  static Future<void> finishOrder(
      BuildContext context,
      String uidOrder,
      ) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore
        .collection("Pedidos")
        .doc(uidOrder)
        .update({"status": "Finalizado"})
        .then((value) => Navigator.pop(context));
  }

  static Future<void> cancelOrder(
      BuildContext context,
      DBOrderModel order,
      ) async {
    if (order.status == 'Cancelado') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este pedido já está cancelado.')),
      );
      return;
    }

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('Pedidos').doc(order.uidOrder).update({
        'status': 'Cancelado',
      });
      debugPrint('Status do pedido ${order.uidOrder} atualizado para Cancelado.');

      for (var productItem in order.productsData) {
        await incrementProductQuantity(
          catalogId: order.uidCatalog,
          productId: productItem['productId'],
          quantityToAdd: productItem['quantity'],
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido cancelado com sucesso e estoque restaurado!')),
      );

    } catch (e) {
      debugPrint('Erro ao cancelar pedido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cancelar pedido: $e')),
      );
    }
  }

  static Future<void> incrementProductQuantity({
    required String catalogId,
    required String productId,
    required int quantityToAdd,
  }) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final DocumentReference productRef = firestore
          .collection('Catalogos')
          .doc(catalogId)
          .collection('Produtos')
          .doc(productId);

      await firestore.runTransaction((transaction) async {
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          debugPrint('Erro: Produto com ID $productId não encontrado no catálogo $catalogId para incremento.');
          return;
        }

        final String currentQuantityString = productDoc.get('quantidade') as String;
        int currentQuantity = int.tryParse(currentQuantityString) ?? 0;

        int newQuantity = currentQuantity + quantityToAdd;

        transaction.update(productRef, {
          'quantidade': newQuantity.toString(), // Salva de volta como String
        });
      });

      debugPrint('Quantidade do produto $productId (Catálogo: $catalogId) incrementada em $quantityToAdd.');
    } catch (e) {
      debugPrint('Erro ao incrementar a quantidade do produto no Firestore: $e');
    }
  }
}