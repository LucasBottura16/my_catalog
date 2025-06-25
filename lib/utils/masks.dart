import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class MasksInput {

  static var cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', // Define a máscara do CPF
      filter: {"#": RegExp(r'[0-9]')}, // Permite apenas dígitos de 0 a 9
      type: MaskAutoCompletionType.lazy // Completa a máscara automaticamente
  );

  static var phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', // Máscara para celular com 9 dígitos
      filter: {"#": RegExp(r'[0-9]')}, // Permite apenas dígitos
      type: MaskAutoCompletionType.lazy
  );

  static var cnpjFormatter = MaskTextInputFormatter(
      mask: '##.###.###/####-##', // Define a máscara do CNPJ
      filter: {"#": RegExp(r'[0-9]')}, // Permite apenas dígitos
      type: MaskAutoCompletionType.lazy // Tipo de preenchimento da máscara
  );

}