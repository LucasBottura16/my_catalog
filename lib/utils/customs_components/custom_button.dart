import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final Color? titleColor;
  final double? titleSize;
  final FontWeight? titleFontWeight;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final Color? buttonColor;
  final double? buttonBorderRadius;
  final EdgeInsets? buttonEdgeInsets;
  final bool? isLoading;
  final Color? loadingColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.titleColor,
    this.titleSize,
    this.titleFontWeight,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.buttonColor,
    this.buttonBorderRadius,
    this.buttonEdgeInsets,
    this.isLoading,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? Center(
        child: CircularProgressIndicator(
          color: loadingColor,
        ))
        : ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
            (Set<WidgetState> states) {
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius ?? 15),
              );
            },
          ),
          backgroundColor:
              WidgetStateProperty.all<Color>(buttonColor ?? Colors.white),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              buttonEdgeInsets ??
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
        ),
        child: Row(
          mainAxisAlignment: icon == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: titleSize,
                  fontWeight: titleFontWeight,
                )),
            Icon(
              icon,
              color: iconColor,
              size: iconSize,
            )
          ],
        ));
  }
}
