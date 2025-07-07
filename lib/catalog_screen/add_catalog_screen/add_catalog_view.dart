import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/add_catalog_screen/add_catalog_service.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:my_catalog/utils/customs_components/custom_image_picker.dart';
import 'package:my_catalog/utils/customs_components/custom_input_field.dart';
import '../../create_account_screen/components/add_categories_modal.dart';

class AddCatalogView extends StatefulWidget {
  const AddCatalogView({super.key});

  @override
  State<AddCatalogView> createState() => _AddCatalogViewState();
}

class _AddCatalogViewState extends State<AddCatalogView> {
  final TextEditingController _controllerCatalog = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoadingCategories = true;
  bool _isLoading = false;

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

  String _pickerValue = "Sem Imagem";

  void _setPicker(String imagePath) {
    setState(() {
      _pickerValue = imagePath;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _controllerCatalog.dispose();
    _controllerDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Catalog',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: MyColors.myPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("FOTO DA CAPA"),
                  ImageSelectionButton(
                    currentImagePath: _pickerValue,
                    onImageSelected: _setPicker,
                    buttonBackgroundColor: MyColors.myPrimary,
                    borderRadius: 15.0,
                  ),
                  CustomInputField(
                      controller: _controllerCatalog,
                      labelText: "NOME",
                      hintText: "Digite o nome do catálogo"),
                  Row(
                    children: [
                      Text("CATEGORIA",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 18)),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
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
                                      .map<DropdownMenuItem<String>>(
                                          (String category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                  CustomInputField(
                    controller: _controllerDescription,
                    labelText: "DESCRICAO",
                    hintText: "Digite a descrição do catálogo",
                    maxLines: 4,
                    maxLength: 120,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                   await AddCatalogService.addCatalog(
                        context,
                        _controllerCatalog.text,
                        _controllerDescription.text,
                        _pickerValue,
                        _selectedCategory ?? "");
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  title: "CADASTRAR CATÁLOGO",
                  titleColor: Colors.white,
                  titleSize: 16,
                  buttonEdgeInsets: const EdgeInsets.symmetric(vertical: 25),
                  buttonColor: MyColors.myPrimary,
                  buttonBorderRadius: 0,
                  isLoading: _isLoading,
                  loadingColor: MyColors.myPrimary,
                )),
          ),
          _isLoading ? const SizedBox(height: 20) : const SizedBox(),
        ],
      ),
    );
  }
}
