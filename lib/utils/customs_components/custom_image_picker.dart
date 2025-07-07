import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_catalog/utils/colors.dart';

class ImageSelectionButton extends StatelessWidget {
  final String currentImagePath;
  final Function(String) onImageSelected;
  final double height;
  final Color buttonBackgroundColor;
  final Color buttonIconColor;
  final double buttonIconSize;
  final double borderRadius;
  final IconData addPhotoIcon;

  const ImageSelectionButton({
    super.key,
    required this.currentImagePath,
    required this.onImageSelected,
    this.height = 200.0,
    this.buttonBackgroundColor = MyColors.myPrimary,
    this.buttonIconColor = Colors.white,
    this.buttonIconSize = 45.0,
    this.borderRadius = 8.0,
    this.addPhotoIcon = Icons.add_a_photo,
  });

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    void handleImagePicking() async {
      final picker = ImagePicker();
      try {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          onImageSelected(pickedFile.path); // Sempre retorna o path local
          debugPrint('Imagem selecionada (local): ${pickedFile.path}');
        } else {
          debugPrint('Seleção de imagem cancelada.');
        }
      } catch (e) {
        debugPrint("Erro ao selecionar imagem: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar imagem: ${e.toString()}')),
        );
      }
    }

    Widget buildImageWidget() {
      if (currentImagePath == "Sem Imagem" || currentImagePath.isEmpty) {
        return ElevatedButton(
          onPressed: handleImagePicking,
          style: ButtonStyle(
            shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
                  (Set<WidgetState> states) {
                return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                );
              },
            ),
            backgroundColor:
            WidgetStateProperty.all<Color>(buttonBackgroundColor),
          ),
          child: Icon(
            addPhotoIcon,
            color: buttonIconColor,
            size: buttonIconSize,
          ),
        );
      }
      else if (_isNetworkImage(currentImagePath)) {
        return GestureDetector(
          onTap: handleImagePicking,
          onLongPress: () {
            onImageSelected("Sem Imagem"); // Permite remover a imagem de rede
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.network(
              currentImagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Erro ao carregar imagem de rede: $error');
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.broken_image,
                        size: buttonIconSize, color: Colors.grey[600]),
                  ),
                );
              },
            ),
          ),
        );
      }
      else {
        return GestureDetector(
          onTap: handleImagePicking,
          onLongPress: () {
            onImageSelected("Sem Imagem"); // Permite remover a imagem local
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.file(
              File(currentImagePath), // Usa File para caminhos locais
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Erro ao carregar imagem de arquivo: $error');
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.broken_image,
                        size: buttonIconSize, color: Colors.grey[600]),
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: buildImageWidget(),
    );
  }
}