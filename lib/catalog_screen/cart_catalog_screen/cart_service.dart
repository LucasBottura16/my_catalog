import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/cart_catalog_screen/components/cart_manager.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/orders_screen/models/order_model.dart';
import 'package:my_catalog/utils/random_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addOrder({
    required BuildContext context,
    required DBAddCatalog catalog,
    required List<CartItem> cartItems,
  }) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DBOrderModel dbOrderModel = DBOrderModel();

      List<Map<String, dynamic>> productsData = [];
      for (var item in cartItems) {
        productsData.add({
          'productId': item.product.uid, // The UID of the product
          'productName': item.product.nameProduct,
          'quantity': item.quantity,
          'unitPrice': item.product.priceProduct,
          'totalItemPrice': item.totalPriceFormatted,
          'imageProduct': item.product.imageProduct,
        });
      }

      dbOrderModel.orderDate = Timestamp.now().toDate();
      dbOrderModel.totalAmount = CartManager.totalCartPriceFormatted;
      dbOrderModel.productsData = productsData;
      dbOrderModel.status = 'Pendente';
      dbOrderModel.uidCustomer = prefs.getString('uid')!;
      dbOrderModel.uidCompany = catalog.uidCompany;
      dbOrderModel.uidCatalog = catalog.uid;
      dbOrderModel.nameCatalog = catalog.catalogName;
      dbOrderModel.nameCompany = catalog.nameCompany;
      dbOrderModel.nameCustomer = prefs.getString('name') ?? '';
      dbOrderModel.emailCustomer = prefs.getString('email') ?? '';
      dbOrderModel.phoneCustomer = prefs.getString('phone') ?? '';
      dbOrderModel.addressCustomer = prefs.getString('address') ?? '';
      dbOrderModel.phoneCompany = catalog.phoneCompany;


      String uid = RandomKeys().generateRandomString();

      await firestore.collection('Pedidos').doc(uid).set(dbOrderModel.toMap(uid));

      for (var item in cartItems) {
        await CartService.updateProductQuantityAfterOrder(
          catalogId: catalog.uid,
          productId: item.product.uid,
          orderedQuantity: item.quantity,
        );
      }

      CartManager.clearCart();

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
    }
  }

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