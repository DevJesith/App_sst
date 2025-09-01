import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class inputReutilizables extends StatelessWidget {
  final TextEditingController controller;
  //final String label;
  final String nameInput;
  final TextInputType keyboardType;
  final bool obscuredText;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;
  final int maxLines;
  final int? maxLenght;
  

  const inputReutilizables({
    Key? key,
    required this.controller,
    //required this.label,
    required this.nameInput,
    required this.validator,
    this.decoration,
    this.maxLines = 1,
    this.maxLenght,
    this.obscuredText = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nameInput,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10,),

        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscuredText,
          maxLines: maxLines,
          maxLength: maxLenght,
          decoration: decoration ?? InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CupertinoColors.inactiveGray, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide( color: CupertinoColors.activeBlue, width: 2),
              borderRadius: BorderRadius.circular(5)
            )
          ),
        ),
      ],
    );
  }
}
