import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/create_account_screen/components/add_categories_modal.dart';
import 'package:my_catalog/create_account_screen/create_account_service.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/masks.dart';

class FormCompany extends StatefulWidget {
  const FormCompany({super.key});

  @override
  State<FormCompany> createState() => _FormCompanyState();
}

class _FormCompanyState extends State<FormCompany> {
  final TextEditingController _controllerCompany = TextEditingController();
  final TextEditingController _controllerCNPJ = TextEditingController();
  final TextEditingController _controllerRepresentative = TextEditingController();
  final TextEditingController _controllerAddress = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  String? _selectedState;

  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoadingCategories = true;

  Future<void> _fetchCategories() async {
    final CollectionReference categoriesCollection =
        FirebaseFirestore.instance.collection('categories');

    Future<List<String>> fetchCategories() async {
      try {
        QuerySnapshot snapshot = await categoriesCollection.get();
        return snapshot.docs.map((doc) => doc['name'] as String).toList();
      } catch (e) {
        debugPrint("Erro ao buscar categorias: $e");
        return [];
      }
    }

    setState(() {
      _isLoadingCategories = true;
    });
    try {
      List<String> fetchedCategories = await fetchCategories();
      setState(() {
        _categories = fetchedCategories;
        _categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        if (_selectedCategory != null &&
            !_categories.contains(_selectedCategory)) {
          _selectedCategory = null;
        }
      });
    } catch (e) {
      debugPrint("Falha ao buscar categorias: $e");
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _addCategoriesModal() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AddCategoriesModal(
            allCategories: _categories,
          );
        });

    _fetchCategories();
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _controllerCompany.dispose();
    _controllerCNPJ.dispose();
    _controllerRepresentative.dispose();
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
        const Text("INFORMAÇÕES DA EMPRESA",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("EMPRESA",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
        TextFormField(
          decoration: const InputDecoration(
            hintText: "Digite o nome da empresa",
          ),
          controller: _controllerCompany,
        ),
        const SizedBox(height: 10),
        const Text("CNPJ",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
        TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            MasksInput.cnpjFormatter,
          ],
          decoration: const InputDecoration(
            hintText: "00.000.000/0000-00",
          ),
          controller: _controllerCNPJ,
        ),
        const SizedBox(height: 10),
        const Text("REPRESENTANTE",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
        TextFormField(
          decoration: const InputDecoration(
            hintText: "nome do representante",
          ),
          controller: _controllerRepresentative,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text("CATEGORIA",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
            TextButton(
                onPressed: _addCategoriesModal,
                child: const Text(
                  "adicionar categoria",
                  style: TextStyle(color: MyColors.myPrimary),
                ))
          ],
        ),
        _isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : _categories.isEmpty
                ? const Text(
                    'Nenhuma categoria disponível. Clique em "Cadastrar Nova Categoria" para adicionar uma.')
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        hint: const Text('Escolha uma categoria'),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.teal),
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 16),
                        dropdownColor: Colors.white,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                            debugPrint(
                                'Categoria selecionada: $_selectedCategory');
                          });
                        },
                        items: _categories
                            .map<DropdownMenuItem<String>>((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
        const SizedBox(height: 10),
        const Text("ESTADO",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
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
                  .map<DropdownMenuItem<String>>((String estado) {
                return DropdownMenuItem<String>(
                  value: estado,
                  child: Text(estado),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text("ENDEREÇO",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
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
                  "Empresa",
                  "null",
                  "null",
                  _selectedState.toString(),
                  _controllerAddress.text,
                  _controllerPhone.text,
                  _controllerCompany.text,
                  _controllerCNPJ.text,
                  _controllerRepresentative.text,
                  _selectedCategory.toString(),
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
