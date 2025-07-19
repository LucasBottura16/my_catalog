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
                  onPressed: () {
                    _deleteOrder();
                  },
                )
              : const SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        // <--- Adicionado SingleChildScrollView aqui
        child: Column(
          // Outer Column
          crossAxisAlignment:
              CrossAxisAlignment.start, // Para alinhar o conteúdo à esquerda
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detalhes do cliente",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Nome: ${_order.nameCustomer}"),
                  Text("Email: ${_order.emailCustomer}"),
                  Text("Telefone: ${_order.phoneCustomer}"),
                  Text("Endereço: ${_order.addressCustomer}"),
                  const SizedBox(height: 20),
                  CustomButton(
                    onPressed: () {
                      debugPrint(_order.productsData.toString());
                    },
                    title: "CHAMAR NO WHATSAPP",
                    titleColor: Colors.white,
                    buttonColor: Colors.green,
                    buttonEdgeInsets: const EdgeInsets.fromLTRB(50, 15, 50, 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "DETALHES DO PEDIDO - ${_order.totalAmount}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // <--- Desabilita a própria rolagem da list
              itemCount: _order.productsData.length,
              itemBuilder: (context, index) {
                final cartItem = _order.productsData[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                cartItem["productName"] ?? 'Nome do Produto',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Qtd: ${cartItem["quantity"] ?? 0}'),
                              Text(
                                'Preço Unitário: ${cartItem["unitPrice"] ?? 'R\$ 0,00'}',
                              ),
                              Text(
                                'Subtotal: ${cartItem["totalItemPrice"] ?? 'R\$ 0,00'}',
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
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _order.status == "Pendente"
                    ? () async {
                        setState(() {
                          _isLoading = true;
                        });

                        if (_order.uidCompany == _uid) {
                          await OrderDetailsService.finishOrder(
                              context, _order.uidOrder);
                        } else {
                          await _deleteOrder();
                        }

                        setState(() {
                          _isLoading = false;
                        });
                      }
                    : () {
                        debugPrint("Pedido já finalizado");
                      },
                title: _order.uidCompany != _uid && _order.status == "Pendente"
                    ? "CANCELAR PEDIDO"
                    : _order.status == "Pendente"
                        ? "CONFIRMAR PEDIDO"
                        : _order.status == "Cancelado"
                            ? "PEDIDO CANCELADO"
                            : "PEDIDO FINALIZADO",
                titleColor: Colors.white,
                titleSize: 16,
                buttonEdgeInsets:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                buttonColor:_order.uidCompany != _uid && _order.status == "Pendente"
                    ?  Colors.red
                    : _order.status == 'Pendente'
                    ? Colors.yellow.shade800
                    : _order.status == "Cancelado"
                        ? Colors.red
                        : Colors.green,
                buttonBorderRadius: 0,
                isLoading: _isLoading,
                loadingColor: MyColors.myPrimary,
              ),
            ),
            _isLoading ? const SizedBox(height: 30) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
