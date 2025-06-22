import 'package:flutter/material.dart';
import 'package:my_catalog/utils/colors.dart';

final ButtonStyle loginButtonStyle = ButtonStyle(
  shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
        (Set<WidgetState> states) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      );
    },
  ),
  backgroundColor: WidgetStateProperty.all<Color>(MyColors.mySecondary),
  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
      const EdgeInsets.fromLTRB(20, 13, 20, 13)),
);
