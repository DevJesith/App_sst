import 'package:flutter/material.dart';

/// Boton generico reutilizable para la navegacion o acciones principales.
/// 
/// Permite personalizar color, texot border y padding.
/// Se usa principalmente en la pantalla de bienvenida WelcomeScreen.
class BotonNavegacion extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double borderRadius;
  final TextStyle textStyle;
  final double paddingVertical;
  final double paddingHorizontal;

  const BotonNavegacion({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.blue,
    this.borderRadius = 8.0,
    this.textStyle = const TextStyle(fontSize: 10, color: Colors.white),
    this.paddingVertical = 12.0,
    this.paddingHorizontal = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: paddingVertical,
          horizontal: paddingHorizontal,
        ),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(text, style: textStyle),
    );
  }
}
