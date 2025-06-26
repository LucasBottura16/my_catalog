import 'package:flutter/material.dart';
import 'package:my_catalog/create_account_screen/create_account_service.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/masks.dart';

class FormCustomer extends StatefulWidget {
  const FormCustomer({super.key});

  @override
  State<FormCustomer> createState() => _FormCustomerState();
}

class _FormCustomerState extends State<FormCustomer> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerCPF = TextEditingController();
  final TextEditingController _controllerAddress = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  String? _selectedState;

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerCPF.dispose();
    _controllerAddress.dispose();
    _controllerPhone.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("INFORMAÇÕES PESSOAIS",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("NOME", style: TextStyle(fontWeight: FontWeight.w400)),
        TextFormField(
          decoration: const InputDecoration(
            hintText: "Digite seu nome",
          ),
          controller: _controllerName,
        ),
        const SizedBox(height: 10),
        const Text("CPF", style: TextStyle(fontWeight: FontWeight.w400)),
        TextFormField(
          controller: _controllerCPF,
          keyboardType: TextInputType.number,
          inputFormatters: [
            MasksInput.cpfFormatter,
          ],
          decoration: const InputDecoration(
            hintText: "000.000.000-00",
          ),
        ),
        const SizedBox(height: 10),
        const Text("ESTADO", style: TextStyle(fontWeight: FontWeight.w400)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedState,
              hint: const Text('Escolha um estado'),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              dropdownColor: Colors.white,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedState = newValue;
                });
              },
              items: CreateAccountService.listStates()
                  .map<DropdownMenuItem<String>>((String state) {
                return DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text("ENDEREÇO", style: TextStyle(fontWeight: FontWeight.w400)),
        TextFormField(
          decoration: const InputDecoration(
            hintText: "nome da rua",
          ),
          controller: _controllerAddress,
        ),
        const SizedBox(height: 10),
        const Text("Telefone", style: TextStyle(fontWeight: FontWeight.w400)),
        TextFormField(
          controller: _controllerPhone,
          keyboardType: TextInputType.number,
          inputFormatters: [MasksInput.phoneFormatter],
          decoration: const InputDecoration(
            hintText: "(11) 9 9999-9999",
          ),
        ),
        const SizedBox(height: 20),
        const Text("INFORMAÇÕES DA CONTA",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("EMAIL", style: TextStyle(fontWeight: FontWeight.w400)),
        TextFormField(
          decoration: const InputDecoration(
            hintText: "exemplo@email.com",
          ),
          controller: _controllerEmail,
        ),
        const SizedBox(height: 10),
        const Text("SENHA", style: TextStyle(fontWeight: FontWeight.w400)),
        TextFormField(
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "******",
          ),
          controller: _controllerPassword,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
            onPressed: () {

              CreateAccountService.createAccount(
                  context,
                  "Cliente",
                  _controllerName.text,
                  _controllerCPF.text,
                  _selectedState.toString(),
                  _controllerAddress.text,
                  _controllerPhone.text,
                  "null",
                  "null",
                  "null",
                  "null",
                  _controllerEmail.text,
                  _controllerPassword.text);
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
                (Set<WidgetState> states) {
                  return RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  );
                },
              ),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.fromLTRB(50, 15, 50, 15)),
              backgroundColor:
                  WidgetStateProperty.all<Color>(MyColors.myPrimary),
            ),
            child: Text("CRIAR CONTA", style: TextStyle(color: Colors.white))),
      ],
    );
  }
}
