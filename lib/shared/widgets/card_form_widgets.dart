import 'package:flutter/material.dart';

/// Tarjeta interactiva para el menú de selección de formularios (Home).
///
/// Muestra un ícono grande dentro de un contenedor con borde y una etiqueta de texto debajo.
class CardForm extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icono;
  final double size;
  final double borderRadius;
  final Color borderColor; 
  final String typeForm;
  final TextStyle typeStyle;

  const CardForm({
    super.key,
    required this.onPressed,
    required this.icono,
    required this.typeForm,
    this.borderColor = const Color(0xFF1976D2), // Azul por defecto
    this.typeStyle = const TextStyle(
      fontSize: 14, // Un poco más pequeño para que quepa bien
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
    this.borderRadius = 20.0, // Más redondeado como en la imagen de la profe
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón con el ícono/imagen
        SizedBox(
          height: size,
          width: size,
          child: Material(
            color: Colors.white,
            elevation: 4, // Sombrita suave
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: borderColor,
                width: 3.0, // Borde grueso como en la imagen
              ),
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: icono,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Etiqueta de texto
        Text(
          typeForm,
          style: typeStyle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}