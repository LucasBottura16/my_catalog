import 'package:flutter/material.dart';
import 'package:my_catalog/utils/colors.dart';

class CustomCatalog extends StatelessWidget {
  final String title;
  final String? textButton;
  final String imageUrl;
  final VoidCallback? onPressed;
  final bool isCompactMode;

  const CustomCatalog({
    super.key,
    required this.title,
    this.textButton = "Acessar",
    this.imageUrl = "Sem Imagem",
    this.onPressed,
    this.isCompactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1000;

    // Responsive dimensions - all values converted to double
    final double imageHeight = isCompactMode
        ? 120.0
        : isMobile
        ? screenSize.height * 0.18  // 18% of screen height on mobile
        : isTablet
        ? 160.0
        : 180.0;

    final double titleFontSize = isCompactMode
        ? 14.0
        : isMobile
        ? 16.0
        : isTablet
        ? 18.0
        : 20.0;

    final int titleMaxLines = isCompactMode ? 2 : 1;
    final double buttonHeight = isCompactMode
        ? 32.0
        : isMobile
        ? 36.0
        : isTablet
        ? 40.0
        : 44.0;

    final double buttonHorizontalPadding = isCompactMode
        ? 10.0
        : isMobile
        ? 12.0
        : isTablet
        ? 14.0
        : 16.0;

    final double bottomPadding = isCompactMode ? 8.0 : 4.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              child: Container(
                height: imageHeight,
                color: MyColors.myTertiary,
                child: _buildImageContent(imageHeight),
              ),
            ),
            // Bottom content (title + button)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: bottomPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        title,
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                        ),
                      ),
                    ),
                  ),
                  // Button
                  SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.myPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: buttonHorizontalPadding,
                        ),
                        minimumSize: Size(0.0, buttonHeight),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        textButton ?? "Acessar",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(double imageHeight) {
    if (imageUrl == "Sem Imagem" || imageUrl.isEmpty) {
      return Center(
        child: Image.asset(
          "images/Logo.png",
          fit: BoxFit.contain,
          width: imageHeight * 0.7,
          height: imageHeight * 0.7,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
            color: MyColors.myPrimary,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Erro ao carregar imagem de catálogo: $error');
        return Center(
          child: Image.asset(
            "images/Logo.png",
            fit: BoxFit.contain,
            width: imageHeight * 0.7,
            height: imageHeight * 0.7,
          ),
        );
      },
    );
  }
}