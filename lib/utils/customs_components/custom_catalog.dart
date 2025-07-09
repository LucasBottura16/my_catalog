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
    return Card(
          elevation: 4,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 120,
                  color: MyColors.myTertiary,
                  child: imageUrl == "Sem Imagem"
                      ? Image.asset("images/Logo.png")
                      : Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: onPressed,
                          style: ButtonStyle(
                            shape:
                                WidgetStateProperty.resolveWith<OutlinedBorder>(
                              (Set<WidgetState> states) {
                                return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                );
                              },
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                                MyColors.myPrimary),
                          ),
                          child: Text(textButton ?? "Acessar",
                              style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  )),
            ],
          ),
        );
  }
}
