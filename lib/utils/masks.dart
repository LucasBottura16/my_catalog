import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

class MasksInput {

  static var currencyRealFormatter = CurrencyInputFormatter();

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

class CurrencyInputFormatter extends MaskTextInputFormatter {
  CurrencyInputFormatter({String initialText = ''})
      : super(
    mask: 'R\$ #.###.###.##0,00', // Máscara para valor em Real
    filter: {"#": RegExp(r'[0-9]')},
    initialText: initialText,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove tudo que não for dígito da nova string
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Se a nova string estiver vazia, retorna um valor vazio
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Adiciona zeros à esquerda se necessário para garantir pelo menos 2 casas decimais
    // Ex: "1" -> "001", "12" -> "012"
    while (newText.length < 3) {
      newText = '0$newText';
    }

    // Converte a string para um número inteiro (tratando como centavos)
    int value = int.parse(newText);

    // Formata o número como moeda
    String formattedValue = (value / 100).toStringAsFixed(2); // Divide por 100 para obter o valor com decimais
    List<String> parts = formattedValue.split('.'); // Separa parte inteira e decimal

    String integerPart = parts[0];
    String decimalPart = parts[1];

    // Adiciona separadores de milhar à parte inteira
    String result = '';
    for (int i = 0; i < integerPart.length; i++) {
      result += integerPart[i];
      // Adiciona ponto a cada 3 dígitos, exceto se for o último dígito ou se não houver mais 3 dígitos à frente
      if ((integerPart.length - 1 - i) % 3 == 0 && (integerPart.length - 1 - i) != 0) {
        result += '.';
      }
    }

    formattedValue = 'R\$ $result,$decimalPart';

    // Aplica a formatação e retorna o valor
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}