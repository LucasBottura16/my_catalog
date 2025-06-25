import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/utils/colors.dart';

class AddCategoriesModal extends StatefulWidget {
   const AddCategoriesModal({super.key, required this.allCategories});

   final List<String> allCategories;

   @override
  State<AddCategoriesModal> createState() => _AddCategoriesModalState();
}

class _AddCategoriesModalState extends State<AddCategoriesModal> {
  final TextEditingController _newCategoryController = TextEditingController();

  final CollectionReference _categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  Future<void> addCategory() async {

    final String newCategoryName =
    _newCategoryController.text.trim();

    if (newCategoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'O nome da categoria não pode ser vazio.')),
      );
      return;
    }

    if (widget.allCategories.contains(newCategoryName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Esta categoria já existe.')),
      );
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Adicionando categoria...')),
    );

    try {
      await _categoriesCollection.add({'name': newCategoryName});
      debugPrint(
          "Categoria '$newCategoryName' adicionada com sucesso ao Firestore!");
    } catch (e) {
      debugPrint("Erro ao adicionar categoria '$newCategoryName': $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.backspace_rounded, size: 20),
                SizedBox(width: 10),
                Text(
                  "FECHAR",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                )
              ],
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Cadastrar Nova Categoria',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    hintText: "Nome da Categoria",
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancelar',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    child: Text('Adicionar',
                        style: TextStyle(
                            color: MyColors.myPrimary,
                            fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await addCategory();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
