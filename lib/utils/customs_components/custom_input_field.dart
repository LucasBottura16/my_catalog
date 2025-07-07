import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? suffix;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autoFocus;
  final TextCapitalization textCapitalization;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? spacingHeight;
  final TextStyle? labelTextStyle;
  final EdgeInsetsGeometry? contentPadding;
  final UnderlineInputBorder? enabledBorder;
  final UnderlineInputBorder? focusedBorder;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = '',
    this.hintStyle,
    this.suffix,
    this.style,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autoFocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.spacingHeight = 10,
    this.labelTextStyle,
    this.contentPadding,
    this.enabledBorder,
    this.focusedBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacingHeight),
        labelText == "Sem texto" ? const SizedBox() :
        Text(
          labelText,
          style: labelTextStyle ?? const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          readOnly: readOnly,
          textCapitalization: textCapitalization,
          style: style,
          maxLength: maxLength,
          autofocus: autoFocus,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            suffix: suffix != null ? Text(suffix!) : null,
            contentPadding: contentPadding,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
          ),
        ),
      ],
    );
  }
}