import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/product_catalog_screen/product_service.dart';
import 'package:my_catalog/catalog_screen/models/catalog_model.dart';
import 'package:my_catalog/catalog_screen/models/product_model.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:my_catalog/utils/customs_components/custom_image_picker.dart';
import 'package:my_catalog/utils/customs_components/custom_input_field.dart';
import 'package:my_catalog/utils/masks.dart';

class ProductModal extends StatefulWidget {
  const ProductModal({super.key, this.catalog, this.editCatalog});

  final DBAddCatalog? catalog;
  final DBProductModel? editCatalog;

  @override
  State<ProductModal> createState() => _ProductModalState();
}

class _ProductModalState extends State<ProductModal> {
  final TextEditingController _nameProductController = TextEditingController();
  final TextEditingController _descriptionProductController =
      TextEditingController();
  final TextEditingController _priceProductController = TextEditingController();
  final TextEditingController _quantityProductController =
      TextEditingController();

  late final DBAddCatalog _catalog;

  bool _isEditing = false;

  DBProductModel? _currentEditProduct;

  bool _isLoading = false;

  String _pickerValue = "Sem Imagem";

  void _setPicker(String imagePath) {
    setState(() {
      _pickerValue = imagePath;
    });
  }

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog!;

    _isEditing = widget.editCatalog != null;

    if (_isEditing) {
      _currentEditProduct = widget.editCatalog;

      _nameProductController.text = _currentEditProduct!.nameProduct;
      _descriptionProductController.text =
          _currentEditProduct!.descriptionProduct;

      _priceProductController.text = _currentEditProduct!.priceProduct;

      _quantityProductController.text = _currentEditProduct!.quantityProduct;

      _pickerValue = _currentEditProduct!.imageProduct;
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
            child: Row(
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
              ImageSelectionButton(
                currentImagePath: _pickerValue,
                onImageSelected: _setPicker,
                buttonBackgroundColor: MyColors.myPrimary,
                borderRadius: 15.0,
              ),
              const SizedBox(height: 10),
              CustomInputField(
                controller: _nameProductController,
                labelText: "NOME",
                hintText: "Digite o nome do produto",
              ),
              const SizedBox(height: 10),
              CustomInputField(
                controller: _descriptionProductController,
                labelText: "DESCRICAO",
                hintText: "Digite a descrição do produto",
                maxLines: 4,
                maxLength: 120,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: CustomInputField(
                    controller: _priceProductController,
                    labelText: "PREÇO",
                    hintText: "R\$ 0,00",
                    keyboardType: TextInputType.number,
                    inputFormatters: [MasksInput.currencyRealFormatter],
                  )),
                  const SizedBox(width: 20),
                  Expanded(
                      child: CustomInputField(
                    controller: _quantityProductController,
                    labelText: "QUANTIDADE",
                    hintText: "0",
                    keyboardType: TextInputType.number,
                    suffix: "Unidades",
                  )),
                ],
              ),
              const SizedBox(height: 10),
              CustomButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  if (_isEditing) {
                    await ProductService.editProduct(
                        context,
                        _catalog.uid,
                        _currentEditProduct!.uid,
                        _nameProductController.text,
                        _descriptionProductController.text,
                        _priceProductController.text,
                        _quantityProductController.text,
                        _pickerValue);
                  } else {
                    await ProductService.addProduct(
                        context,
                        _catalog.uid,
                        _nameProductController.text,
                        _descriptionProductController.text,
                        _priceProductController.text,
                        _quantityProductController.text,
                        _pickerValue);
                  }

                  setState(() {
                    _isLoading = false;
                  });
                },
                title: _isEditing ? "EDITAR PRODUTO" : "CADASTRAR NOVO PRODUTO",
                titleColor: Colors.white,
                buttonColor: MyColors.myPrimary,
                buttonBorderRadius: 15.0,
                buttonEdgeInsets: const EdgeInsets.symmetric(vertical: 15),
                isLoading: _isLoading,
                loadingColor: MyColors.myPrimary,
              )
            ],
          ),
        ),
      ),
    );
  }
}
