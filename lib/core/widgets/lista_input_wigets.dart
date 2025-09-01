import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListaInputWigets extends StatelessWidget {
  final String label;
  final String nameInput;
  final List<String> items;
  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;

  const ListaInputWigets({
    Key? key,
    required this.label,
    required this.nameInput,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.validator,
    this.decoration,
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

        const SizedBox(height: 10),

        DropdownButtonFormField(
          isExpanded: true,
          value: value,
          onChanged: onChanged,
          validator: validator,
          decoration:
              decoration ??
              InputDecoration(
                labelText: label,
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
              ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
        ),
      ],
    );
  }
}
