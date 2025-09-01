// import 'package:app_sst/core/widgets/card_form_widgets.dart';
// import 'package:app_sst/features/forms/presentacion/screens/accidente_form.dart';
// import 'package:app_sst/features/forms/presentacion/screens/capacitacion_form.dart';
// import 'package:app_sst/features/forms/presentacion/screens/enfermedad_form.dart';
// import 'package:app_sst/features/forms/presentacion/screens/incidente_form.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// class HomeScreens extends HookConsumerWidget {
//   const HomeScreens({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Reportar Riesgo",
//           style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
//         ),
//         toolbarHeight: 70,
//         actionsPadding: EdgeInsets.symmetric(horizontal: 20),
//         automaticallyImplyLeading: true,
//         leadingWidth: 30,
//         backgroundColor: const Color.fromARGB(255, 221, 221, 221),
//         actions: [
//           Icon(
//             Icons.notifications_active,
//             color: CupertinoColors.systemRed,
//             size: 30,
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(20),
//               constraints: BoxConstraints(maxWidth: 400),
//               child: Text(
//                 "Formularios Iniciales De Riesgo",
//                 style: TextStyle(
//                   color: Colors.blue[900],
//                   fontWeight: FontWeight.bold,
//                   fontSize: 30,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),

//             const SizedBox(height: 20),

//             SizedBox(
//               height: 400,
//               child: GridView.count(
//                 crossAxisCount: 2, // Dos columnas
//                 crossAxisSpacing: 20,
//                 mainAxisSpacing: 10,
//                 physics: NeverScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(20),
//                 children: [
//                   CardForm(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => AccidenteForm()),
//                       );
//                     },
//                     icono: Image.asset('assets/images/lesion-laboral.png', height: 80, width: 80,),
//                     typeForm: "Accidente",
//                   ),
//                   CardForm(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => IncidenteForm()),
//                       );
//                     },
//                     icono: Image.asset('assets/images/seguimiento.png', height: 80, width: 80,),
//                     typeForm: "Incidente",
//                   ),
//                   CardForm(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => EnfermedadForm()),
//                       );
//                     },
//                     icono: Image.asset('assets/images/enfermedad.png', height: 80, width: 80,),
//                     typeForm: "Enfermedad Laboral",
//                   ),
//                   CardForm(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => CapacitacionForm()),
//                       );
//                     },
//                     icono: Image.asset('assets/images/capacitacion.png', height: 80, width: 80,),
//                     //color: Colors.teal,
//                     typeForm: "Capacitaciones",
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:app_sst/core/widgets/card_form_widgets.dart';
import 'package:app_sst/features/forms/presentacion/screens/accidente_form.dart';
import 'package:app_sst/features/forms/presentacion/screens/capacitacion_form.dart';
import 'package:app_sst/features/forms/presentacion/screens/enfermedad_form.dart';
import 'package:app_sst/features/forms/presentacion/screens/incidente_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreens extends HookConsumerWidget {
  const HomeScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          "Reportar Riesgo",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
        toolbarHeight: 70,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20),
        automaticallyImplyLeading: true,
        leadingWidth: 30,
        backgroundColor: const Color.fromARGB(255, 221, 221, 221),
        actions: const [
          Icon(
            Icons.notifications_active,
            color: CupertinoColors.systemRed,
            size: 30,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 800 ? 3 : 2;

          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Text(
                      "Formularios Iniciales De Riesgo",
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1,
                      children: [
                        CardForm(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AccidenteForm()),
                            );
                          },
                          icono: Image.asset('assets/images/lesion-laboral.png', height: 80, width: 80),
                          typeForm: "Accidente",
                        ),
                        CardForm(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const IncidenteForm()),
                            );
                          },
                          icono: Image.asset('assets/images/seguimiento.png', height: 80, width: 80),
                          typeForm: "Incidente",
                        ),
                        CardForm(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EnfermedadForm()),
                            );
                          },
                          icono: Image.asset('assets/images/enfermedad.png', height: 80, width: 80),
                          typeForm: "Enfermedad Laboral",
                        ),
                        CardForm(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CapacitacionForm()),
                            );
                          },
                          icono: Image.asset('assets/images/capacitacion.png', height: 80, width: 80),
                          typeForm: "Capacitaciones",
                        ),

                        // ✅ Puedes agregar más formularios aquí sin romper el diseño
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}