import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_catalog/orders_screen/models/order_model.dart';
import 'package:my_catalog/orders_screen/order_list/order_list_service.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  final _controllerStreamCustomer = StreamController<QuerySnapshot>.broadcast();
  final _controllerStreamCompany = StreamController<QuerySnapshot>.broadcast();

  bool _selectedButton = true;

  String _typeAccount = "";

  Stream<QuerySnapshot>? _currentOrdersStream;

  _verifyAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _typeAccount = prefs.getString('typeAccount') ?? '';
    });
  }

  void _updateSelectedButton(bool value) {
    setState(() {
      _selectedButton = value;

      if (value) {
        OrderService.addListenerOrderCustomer(_controllerStreamCustomer);
        _currentOrdersStream = _controllerStreamCustomer.stream;
      } else {
        OrderService.addListenerOrderCompany(_controllerStreamCompany);
        _currentOrdersStream = _controllerStreamCompany.stream;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentOrdersStream = _controllerStreamCustomer.stream;

    OrderService.addListenerOrderCustomer(_controllerStreamCustomer);
    OrderService.addListenerOrderCompany(_controllerStreamCompany);

    _verifyAccount();
  }

  @override
  Widget build(BuildContext context) {
    // Obtém a largura da tela para decisões de responsividade
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define uma largura máxima para o conteúdo principal em telas grandes (Web)
    final double contentMaxWidth =
        screenWidth > 1000 ? 1000 : screenWidth; // Ex: max 800px

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Pedidos",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: MyColors.myPrimary,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            // A logo pode precisar ser ajustada para telas muito pequenas ou muito grandes
            // Podemos usar um Flexible ou SizedBox com largura máxima/mínima
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0), // Padding para a logo
              child: Image.asset("images/Logo.png",
                  width: 70, height: 70), // Sua logo
            ),
          ],
        ),
        body: Center(
          // Centraliza o conteúdo principal horizontalmente na web
          child: ConstrainedBox(
            // Limita a largura do conteúdo principal
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Padding(
              padding: const EdgeInsets.all(
                  16.0), // Aumentei o padding geral para 16
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botoes de filtro (Meus Pedidos / Pedidos da Empresa)
                  // *** ALTERAÇÃO AQUI: USANDO ROW E EXPANDED PARA FICAREM LADO A LADO ***
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centraliza os botões na Row
                    children: [
                      Expanded(
                        // Ocupa o espaço disponível
                        child: ElevatedButton(
                          onPressed: () {
                            _updateSelectedButton(true);
                          },
                          style: ButtonStyle(
                            shape:
                                WidgetStateProperty.resolveWith<OutlinedBorder>(
                              (Set<WidgetState> states) {
                                return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    width: _selectedButton == true ? 0.0 : 1.0,
                                    color: _selectedButton == true
                                        ? MyColors.myPrimary
                                        : MyColors.myPrimary,
                                  ),
                                );
                              },
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              _selectedButton == true
                                  ? MyColors.myPrimary
                                  : MyColors.mySecondary,
                            ),
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical:
                                        14)), // Aumentei o padding vertical
                          ),
                          child: Text(
                            "Meus Pedidos",
                            textAlign: TextAlign.center, // Centraliza o texto
                            style: TextStyle(
                              color: _selectedButton == true
                                  ? Colors.white
                                  : MyColors.myPrimary,
                              fontSize:
                                  16, // Ajuste o tamanho da fonte se necessário
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // Espaço entre os botões
                      Expanded(
                        // Ocupa o espaço disponível
                        child: ElevatedButton(
                          onPressed: () {
                            _updateSelectedButton(false);
                          },
                          style: ButtonStyle(
                            shape:
                                WidgetStateProperty.resolveWith<OutlinedBorder>(
                              (Set<WidgetState> states) {
                                return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    width: _selectedButton == false ? 0.0 : 1.0,
                                    color: _selectedButton == false
                                        ? MyColors.myPrimary
                                        : MyColors.myPrimary,
                                  ),
                                );
                              },
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              _selectedButton == false
                                  ? MyColors.myPrimary
                                  : MyColors.mySecondary,
                            ),
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical:
                                        14)), // Aumentei o padding vertical
                          ),
                          child: Text(
                            "Pedidos da Empresa",
                            textAlign: TextAlign.center, // Centraliza o texto
                            style: TextStyle(
                              color: _selectedButton == false
                                  ? Colors.white
                                  : MyColors.myPrimary,
                              fontSize:
                                  16, // Ajuste o tamanho da fonte se necessário
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Título da seção (Meus Pedidos / Pedidos da Empresa)
                  Text(
                    _selectedButton ? "Meus Pedidos" : "Pedidos da Empresa",
                    style: const TextStyle(
                      fontSize: 22, // Aumentei o tamanho da fonte
                      fontWeight: FontWeight.bold,
                      color: MyColors.myPrimary,
                    ),
                  ),
                  const SizedBox(
                      height: 10), // Adicionado um pequeno espaçamento
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _currentOrdersStream,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Carregando Pedidos...",
                                      style:
                                          TextStyle(color: MyColors.myPrimary)),
                                  SizedBox(height: 10),
                                  CircularProgressIndicator(
                                      color: MyColors.myPrimary),
                                ],
                              ),
                            );
                          case ConnectionState.active:
                          case ConnectionState.done:
                            if (snapshot.hasError) {
                              debugPrint(
                                  "Erro no StreamBuilder de Pedidos: ${snapshot.error}");
                              return Center(
                                child: Text(
                                    "Erro ao carregar Pedidos: ${snapshot.error}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red)),
                              );
                            }

                            QuerySnapshot? querySnapshot = snapshot.data;

                            if (querySnapshot == null ||
                                querySnapshot.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  "Nenhum Pedido encontrado!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: MyColors.myPrimary),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot documentSnapshot =
                                    querySnapshot.docs[index];
                                DBOrderModel myOrder =
                                    DBOrderModel.fromDocumentSnapshot(
                                        documentSnapshot);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Informações de Data e Status
                                    Row(
                                      children: [
                                        Text(
                                            DateFormat('dd/MM/yyyy')
                                                .format(myOrder.orderDate),
                                            style: const TextStyle(
                                                fontSize: 14) // Ajuste de fonte
                                            ),
                                        const Text(' - ',
                                            style: TextStyle(fontSize: 14)),
                                        Flexible(
                                          // Flexible para o status para evitar overflow
                                          child: Text(
                                            myOrder.status,
                                            style: TextStyle(
                                                fontSize: 14, // Ajuste de fonte
                                                fontWeight: FontWeight
                                                    .bold, // Deixa em negrito para destaque
                                                color:
                                                    myOrder.status == 'Pendente'
                                                        ? Colors.yellow.shade800
                                                        : myOrder.status ==
                                                                "Cancelado"
                                                            ? Colors.red
                                                            : Colors.green),
                                            overflow: TextOverflow
                                                .ellipsis, // Trunca o texto se necessário
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height:
                                            10), // Espaçamento entre data/status e o Card
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            RouteGenerator.orderDetails,
                                            arguments: myOrder);
                                      },
                                      child: Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical:
                                                  5), // Reduzido o margin vertical
                                          elevation:
                                              3, // Adicionado uma pequena sombra
                                          child: Padding(
                                              padding: const EdgeInsets.all(
                                                  15), // Aumentado o padding interno
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center, // Alinha verticalmente no centro
                                                children: [
                                                  Expanded(
                                                    // Usa Expanded para a coluna de texto
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Usado SelectableText para permitir copiar o UID do pedido na web
                                                        SelectableText(
                                                          "Pedido: ${myOrder.uidOrder}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey),
                                                        ),
                                                        const SizedBox(
                                                            height:
                                                                8), // Reduzido o espaçamento
                                                        Text(
                                                          _typeAccount ==
                                                                  "company"
                                                              ? myOrder
                                                                  .nameCustomer
                                                              : myOrder
                                                                  .nameCompany,
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                20, // Aumentei o tamanho da fonte
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          maxLines:
                                                              2, // Limita o nome para não estourar
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          myOrder.nameCatalog,
                                                          style: const TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize:
                                                                  14), // Ajuste de fonte
                                                          maxLines:
                                                              1, // Limita o nome do catálogo
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          10), // Espaço entre o texto e o preço
                                                  Text(
                                                    myOrder.totalAmount,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            18, // Aumentei o tamanho da fonte do preço
                                                        color: myOrder.status ==
                                                                'Pendente'
                                                            ? Colors
                                                                .yellow.shade800
                                                            : myOrder.status ==
                                                                    "Cancelado"
                                                                ? Colors.red
                                                                : Colors.green),
                                                  )
                                                ],
                                              ))),
                                    )
                                  ],
                                );
                              },
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
