import 'package:flutter/material.dart';
import 'package:my_catalog/create_account_screen/components/form_company.dart';
import 'package:my_catalog/create_account_screen/components/form_customer.dart';
import 'package:my_catalog/utils/colors.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  bool _selectedButton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: const EdgeInsets.only(right: 25),
                  height: 70,
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(100)),
                    color: MyColors.myPrimary,
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5),
                                Text("Voltar",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20))
                              ],
                            )),
                      ],
                    ),
                  )),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      "CRIAR CONTA",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedButton = true;
                                });
                              },
                              style: ButtonStyle(
                                shape: WidgetStateProperty.resolveWith<
                                    OutlinedBorder>(
                                  (Set<WidgetState> states) {
                                    return RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                        width:
                                            _selectedButton == true ? 0.0 : 1.0,
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
                                    const EdgeInsets.symmetric(vertical: 12)),
                              ),
                              child: Text("Cliente",
                                  style: TextStyle(
                                      color: _selectedButton == true
                                          ? Colors.white
                                          : MyColors.myPrimary))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedButton = false;
                                  });
                                },
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.resolveWith<
                                      OutlinedBorder>(
                                    (Set<WidgetState> states) {
                                      return RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: BorderSide(
                                          width: _selectedButton == false
                                              ? 0.0
                                              : 1.0,
                                          color: _selectedButton == false
                                              ? MyColors.myPrimary
                                              : MyColors.myPrimary,
                                        ),
                                      );
                                    },
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                    _selectedButton == false
                                        ? MyColors.myPrimary
                                        : MyColors.mySecondary,
                                  ),
                                  padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(vertical: 12)),
                                ),
                                child: Text(
                                  "Empresa",
                                  style: TextStyle(
                                      color: _selectedButton == false
                                          ? Colors.white
                                          : MyColors.myPrimary),
                                )))
                      ],
                    ),
                    const SizedBox(height: 20),
                    _selectedButton == true ? FormCustomer() : FormCompany()
                  ],
                ),
              )
            ],
          )),
        ));
  }
}
