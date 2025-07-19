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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pedidos",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: MyColors.myPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Image.asset("images/Logo.png", width: 70, height: 70), // Sua logo
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _updateSelectedButton(true);
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
                            (Set<WidgetState> states) {
                          return RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: _selectedButton == true ? 0.0 : 1.0,
                              color: _selectedButton == true ? MyColors.myPrimary : MyColors.myPrimary,
                            ),
                          );
                        },
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        _selectedButton == true
                            ? MyColors.myPrimary
                            : MyColors.mySecondary,
                      ),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                    ),
                    child: Text(
                      "Meus Pedidos",
                      style: TextStyle(
                        color: _selectedButton == true
                            ? Colors.white
                            : MyColors.myPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded( // Use Expanded
                  child: ElevatedButton(
                    onPressed: () {
                      _updateSelectedButton(false);
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
                            (Set<WidgetState> states) {
                          return RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: _selectedButton == false ? 0.0 : 1.0,
                              color: _selectedButton == false ? MyColors.myPrimary : MyColors.myPrimary,
                            ),
                          );
                        },
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        _selectedButton == false
                            ? MyColors.myPrimary
                            : MyColors.mySecondary,
                      ),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                    ),
                    child: Text(
                      "Pedidos da Empresa",
                      style: TextStyle(
                        color: _selectedButton == false
                            ? Colors.white
                            : MyColors.myPrimary,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _selectedButton ? "Meus Pedidos" : "Pedidos da Empresa",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MyColors.myPrimary,
              ),
            ),
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
                                style: TextStyle(color: MyColors.myPrimary)),
                            SizedBox(height: 10),
                            CircularProgressIndicator(color: MyColors.myPrimary),
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

                      if (querySnapshot == null || querySnapshot.docs.isEmpty) {
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
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot =
                          querySnapshot.docs[index];
                          DBOrderModel myOrder =
                          DBOrderModel.fromDocumentSnapshot(documentSnapshot);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Text(DateFormat('dd/MM/yyyy')
                                      .format(myOrder.orderDate)),
                                  const Text(' - '),
                                  Text(
                                    myOrder.status,
                                    style: TextStyle(
                                        color: myOrder.status == 'Pendente'
                                            ? Colors.yellow.shade800
                                            : myOrder.status == "Cancelado"
                                            ? Colors.red
                                            : Colors.green),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RouteGenerator.orderDetails,
                                      arguments: myOrder);
                                },
                                child: Card(
                                    margin: const EdgeInsets.symmetric(vertical: 10),
                                    child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                 Text(
                                                  "Pedido: ${myOrder.uidOrder}"),
                                                const SizedBox(height: 10),
                                                Text(
                                                  _typeAccount == "company"
                                                      ? myOrder.nameCustomer
                                                      : myOrder.nameCompany,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  myOrder.nameCatalog,
                                                  style: const TextStyle(
                                                      color: Colors.black54),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              myOrder.totalAmount,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: myOrder.status == 'Pendente'
                                                      ? Colors.yellow.shade800
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
    );
  }
}