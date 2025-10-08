import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Campo de entrada para fechas con selector tipo calendario.
/// Usa `flutter_hooks` para manejar el controlador de texto reactivo.

class FechaInputWidgets extends HookWidget {
  final DateTime? fecha;
  final String label;
  final String nameInput;
  final void Function(DateTime) onchanged;
  final String? Function(String?)? validator;

  const FechaInputWidgets({
    super.key,
    required this.fecha,
    required this.nameInput,
    required this.label,
    required this.onchanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final fechaController = useTextEditingController();

    useEffect(() {
      if (fecha != null) {
        final dia = fecha!.day.toString().padLeft(2, "0");
        final mes = fecha!.month.toString().padLeft(2, "0");
        final ano = fecha!.year.toString();
        fechaController.text = "$dia/$mes/$ano";
      } else {
        fechaController.text = '';
      }
      return null;
    }, [fecha]);

    return GestureDetector(
      onTap: () async {
        final nuevaFecha = await showDatePicker(
          context: context,
          initialDate: fecha ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (nuevaFecha != null) {
          onchanged(nuevaFecha);
        }
      },
      child: AbsorbPointer(
        child: Column(
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

            TextFormField(
              controller: fechaController,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                ),
              ),
              validator: validator,
            ),
          ],
        ),
      ),
    );
  }
}
