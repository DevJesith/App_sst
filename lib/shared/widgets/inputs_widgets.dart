import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Campo de texto generico y reutilizable para formularios.
/// 
/// Encapsula un [TextFormField] con estilos predefinidos
/// y permite configurar validaciones, iconos y tipo de teclado.
/// ignore: camel_case_types
class inputReutilizables extends StatelessWidget {
  final TextEditingController controller;
  final String nameInput;
  final TextInputType keyboardType;
  final bool obscuredText;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;
  final int maxLines;
  final int? maxLenght;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  /// Indica si el campo es de solo lectura (no editable)
  /// Por defecto es 'false'.
  final bool readOnly;

  const inputReutilizables({
    Key? key,
    required this.controller,
    required this.nameInput,
    this.validator,
    this.decoration,
    this.maxLines = 1,
    this.maxLenght,
    this.obscuredText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta superior
        Text(
          nameInput,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        // Campo de texto
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscuredText,
          maxLines: maxLines,
          maxLength: maxLenght,
          readOnly: readOnly,
          decoration:
              decoration ??
              InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                suffixIcon: suffixIcon,
                prefixIcon: prefixIcon,
              ),
        ),
      ],
    );
  }
}
