import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_catalog/utils/colors.dart';

class ImageSelectionButton extends StatelessWidget {
  final String currentImagePath;
  final Function onImageSelected;
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

  @override
  Widget build(BuildContext context) {
    void handleImagePicking() async {
      final picker = ImagePicker();
      try {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          onImageSelected(pickedFile.path);
          debugPrint('Imagem selecionada: ${pickedFile.path}');
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

    return SizedBox(
      height: height,
      width: double.infinity,
      child: currentImagePath == "Sem Imagem"
          ? ElevatedButton(
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
            )
          : GestureDetector(
              onTap: handleImagePicking,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Image.file(
                  File(currentImagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Erro ao carregar imagem: $error');
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
            ),
    );
  }
}
