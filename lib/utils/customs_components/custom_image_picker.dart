import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  Future<void> _handleImagePicking(BuildContext context) async {
    if (kIsWeb) {
      final picker = ImagePicker();
      try {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          onImageSelected(pickedFile.path);
        }
      } catch (e) {
        debugPrint("Erro ao selecionar imagem: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar imagem: ${e.toString()}')),
        );
      }
    } else {
      final picker = ImagePicker();
      try {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          onImageSelected(pickedFile.path);
        }
      } catch (e) {
        debugPrint("Erro ao selecionar imagem: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar imagem: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildPlaceholder(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleImagePicking(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(double.infinity, height),
      ),
      child: Icon(
        addPhotoIcon,
        color: buttonIconColor,
        size: buttonIconSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (currentImagePath == "Sem Imagem" || currentImagePath.isEmpty) {
      imageWidget = _buildPlaceholder(context);
    } else if (_isNetworkImage(currentImagePath)) {
      imageWidget = GestureDetector(
        onTap: () => _handleImagePicking(context),
        onLongPress: () => onImageSelected("Sem Imagem"),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            currentImagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context);
            },
          ),
        ),
      );
    } else {
      imageWidget = GestureDetector(
        onTap: () => _handleImagePicking(context),
        onLongPress: () => onImageSelected("Sem Imagem"),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: kIsWeb
              ? Image.network(
            currentImagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context);
            },
          )
              : Image.file( // Para mobile, usa File
            File(currentImagePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context);
            },
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: imageWidget,
    );
  }
}