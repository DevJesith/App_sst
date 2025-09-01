import 'package:flutter/material.dart';

class CardForm extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icono;
  //final double height;
  //final double width;
  final double size;
  final double borderRadius;
  final Color? color;
  final String typeForm;
  final TextStyle typeStyle;

  CardForm({
    required this.onPressed,
    required this.icono,
    this.color,
    required this.typeForm,
    this.typeStyle = const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
    //this.height = 10.0,
    //this.width = 10.0,
    this.borderRadius = 12.0,
    this.size = 100,
    
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(color: Colors.blue.shade700, width: 3.0),
            ),
          ),
          child: Container(
            height: size,
            width: size,
            alignment: Alignment.center,
            child: icono,
          )
        ),
        const SizedBox(height: 10,),
        Text(typeForm, style: typeStyle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,),
      ],
    );
  }
}
