import 'package:flutter/material.dart';
import 'package:my_catalog/orders_screen/order_details/order_details_service.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart'; // Certifique-se de que este caminho está correto

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({super.key, required this.order});

  final DBOrderModel order;

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  late final DBOrderModel _order;

  String? _uid;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _getUid();
  }

  _getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uid = prefs.getString('uid') ?? '';
    });
  }

  _deleteOrder() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Cancelar Pedido"),
            content:
            const Text("Você tem certeza que deseja cancelar este pedido?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Não"),
              ),
              TextButton(
                onPressed: () async {
                  await OrderDetailsService.cancelOrder(context, _order);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Sim"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    // Define uma largura máxima para o conteúdo principal em telas grandes (Web)
    final double contentMaxWidth = screenWidth > 800
        ? 1000
        : screenWidth; // Ex: max 800px

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalhes do Pedido",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: MyColors.myPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _uid == _order.uidCompany
              ? IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deleteOrder,
            // Desabilita se estiver carregando
            tooltip: 'Excluir Pedido', // Adiciona um tooltip
          )
              : const SizedBox(),
        ],
      ),
      body: Center( // Centraliza o conteúdo principal horizontalmente na web
        child: ConstrainedBox( // Limita a largura do conteúdo principal
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: SingleChildScrollView( // Mantém o SingleChildScrollView para rolagem vertical
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding geral
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detalhes do Cliente
                  Card( // Usar Card para agrupar as informações do cliente
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detalhes do Cliente",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SelectableText("Nome: ${_order.nameCustomer}",
                              style: const TextStyle(fontSize: 15)),
                          // SelectableText
                          SelectableText("Email: ${_order.emailCustomer}",
                              style: const TextStyle(fontSize: 15)),
                          // SelectableText
                          SelectableText("Telefone: ${_order.phoneCustomer}",
                              style: const TextStyle(fontSize: 15)),
                          // SelectableText
                          SelectableText("Endereço: ${_order.addressCustomer}",
                              style: const TextStyle(fontSize: 15)),
                          // SelectableText
                          const SizedBox(height: 20),
                          SizedBox( // Usar SizedBox com double.infinity para o CustomButton
                            width: double.infinity,
                            child: CustomButton(
                              onPressed: _isLoading
                                  ? () {}
                                  : () { // Desabilita se estiver carregando
                                String phoneSelected = _order.uidCompany != _uid
                                    ? _order.phoneCompany
                                    : _order.phoneCustomer;
                                String nameSelected = _order.uidCompany != _uid
                                    ? _order.nameCompany
                                    : _order.nameCustomer;
                                OrderDetailsService.launchWhatsApp(
                                    phoneSelected, nameSelected);
                              },
                              title: _order.uidCompany == _uid
                                  ? "CHAMAR CLEINTE NO WHATSAPP"
                                  : "CHAMAR EMPRESA NO WHATSAPP",
                              titleColor: Colors.white,
                              buttonColor: Colors.green,
                              // Removido buttonEdgeInsets fixos e usei padding interno para o botão
                              buttonEdgeInsets: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              titleSize: 16,
                              buttonBorderRadius: 8,
                              // Adicionado borderRadius
                              isLoading: _isLoading,
                              loadingColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Detalhes do Pedido e Lista de Produtos
                  Text(
                    "DETALHES DO PEDIDO - ${_order.totalAmount}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // Mantém a rolagem no SingleChildScrollView pai
                    itemCount: _order.productsData.length,
                    itemBuilder: (context, index) {
                      final cartItem = _order.productsData[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 8),
                        // Removido horizontal padding aqui, já tem no pai
                        elevation: 2,
                        // Uma leve sombra
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cartItem["imageProduct"] ??
                                      'https://via.placeholder.com/80',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                            Icons.broken_image, size: 35,
                                            color: Colors.grey),
                                      ),
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
                                      cartItem["productName"] ??
                                          'Nome do Produto',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2, // Limita as linhas
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Qtd: ${cartItem["quantity"] ?? 0}'),
                                    Text(
                                      'Preço Unitário: ${cartItem["unitPrice"] ??
                                          'R\$ 0,00'}',
                                    ),
                                    Text(
                                      'Subtotal: ${cartItem["totalItemPrice"] ??
                                          'R\$ 0,00'}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Espaço antes do botão de ação final
                  // Botão de Ação Final (Confirmar/Cancelar/Finalizado)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    // Já tem padding no pai
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: _isLoading
                            ? () {}
                            : _order.status == "Pendente"
                            ? () async {
                          setState(() {
                            _isLoading = true;
                          });
                          if (_order.uidCompany == _uid) {
                            await OrderDetailsService.finishOrder(
                                context, _order.uidOrder);
                          } else {
                            await _deleteOrder(); // Para cliente, 'deletar' pode significar cancelar
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        }
                            : () {
                          // Se o pedido não está pendente, o botão não faz nada (ou exibe uma mensagem)
                          debugPrint("Ação não permitida para pedido ${_order
                              .status}");
                        },
                        title: _order.uidCompany != _uid &&
                            _order.status == "Pendente"
                            ? "CANCELAR PEDIDO"
                            : _order.status == "Pendente"
                            ? "CONFIRMAR PEDIDO"
                            : _order.status == "Cancelado"
                            ? "PEDIDO CANCELADO"
                            : "PEDIDO FINALIZADO",
                        titleColor: Colors.white,
                        titleSize: 16,
                        buttonEdgeInsets: const EdgeInsets.symmetric(
                            vertical: 20),
                        // Ajustado padding vertical
                        buttonColor: _order.uidCompany != _uid &&
                            _order.status == "Pendente"
                            ? Colors.red
                            : _order.status == 'Pendente'
                            ? MyColors
                            .myPrimary // Usar MyColors.myPrimary para 'Pendente' (confirmação)
                            : _order.status == "Cancelado"
                            ? Colors.red
                            : Colors.green,
                        buttonBorderRadius: 8,
                        // Adicionado borderRadius
                        isLoading: _isLoading,
                        loadingColor: Colors.white,
                      ),
                    ),
                  ),
                  _isLoading ? const SizedBox(height: 10) : const SizedBox(
                      height: 10),
                  // Pequeno espaço no final
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
