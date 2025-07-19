import 'package:flutter/material.dart';
import 'package:my_catalog/utils/colors.dart';

class CustomCatalog extends StatelessWidget {
  final String title;
  final String? textButton;
  final String imageUrl;
  final VoidCallback? onPressed;

  const CustomCatalog({
    super.key,
    required this.title,
    this.textButton = "Acessar",
    this.imageUrl = "Sem Imagem",
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12.0),
              ),
              child: Container(
                height: isSmallScreen ? 150 : 180,
                color: MyColors.myTertiary,
                child: imageUrl == "Sem Imagem"
                    ? Center(
                  child: Image.asset(
                    "images/Logo.png",
                    fit: BoxFit.contain,
                    width: 100,
                  ),
                )
                    : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Image.asset(
                        "images/Logo.png",
                        fit: BoxFit.contain,
                        width: 100,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: isSmallScreen ? 36 : 40,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.myPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                        ),
                      ),
                      child: Text(
                        textButton ?? "Acessar",
                        style: const TextStyle(
                          color: Colors.white,
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
}