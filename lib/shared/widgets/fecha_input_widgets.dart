import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Widget reutilizable para la seleccion de fechas.
/// 
/// Muestra un campo de texto que, al ser tocado, abre un calendario.
/// Utiliza flutter_hooks para mantener el texto del controlador sincronizado
/// con la variable [fecha] externa.

class FechaInputWidgets extends HookWidget {
  final DateTime? fecha;
  final String label;
  final String nameInput;

  /// Callback que se ejecuta cuando el usuario selecciona una nueva fecha.
  final void Function(DateTime) onchanged;
  
  /// Funcion de validacion para formularios
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

    // Controlador para mostrar el texto "dd/mm/yyyy"
    final fechaController = useTextEditingController();

    // Efecto: Cada vez que la variable 'fecha' cambia externamente, 
    // actualizamos el texto del controlador.
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
        // Mostrar selector de fecha nativo
        final nuevaFecha = await showDatePicker(
          context: context,
          initialDate: fecha ?? DateTime.now(),
          firstDate: DateTime(2000), // Fecha minima permitida
          lastDate: DateTime.now(), // Fecha maxima
        );
        if (nuevaFecha != null) {
          onchanged(nuevaFecha);
        }
      },
      // AbsorbPointer evita que el teclado se abra al tocar el texto
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
