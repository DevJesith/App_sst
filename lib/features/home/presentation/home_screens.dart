import 'package:app_sst/services/sync_service.dart';
import 'package:app_sst/shared/widgets/card_form_widgets.dart';
import 'package:app_sst/features/forms/accidente/presentation/screens/accidente_form_screen.dart';
import 'package:app_sst/features/forms/capacitacion/presentation/screens/capacitacion_form.dart';
import 'package:app_sst/features/forms/enfermedad/presentation/screens/enfermedad_form.dart';
import 'package:app_sst/features/forms/incidente/presentation/screens/incidente_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla principal para reportar riesgos.
/// Muestra tarjetas para acceder a cada tipo de formulario.
class HomeScreens extends HookConsumerWidget {
  const HomeScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

      //Funcion para manejar la sincronizacion
      Future<void> ejecutarSincronizacion() async {
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>  const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16,),
                    Text("Sincronizando con la nube..."),
                    Text("(Simulacion)", style: TextStyle(fontSize: 10, color: Colors.grey),)
                  ],
                ),
              ),
            ),
          ),
        );

        try {
          
          //Llamar al servicio simulado
          final resultado = await SyncService().sincronizarTodo();

          if (context.mounted) {
            Navigator.pop(context);

            //Mostrar resultado
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("✅ Sincronización Exitosa"),
                content: Text(
                "Se han subido ${resultado['total']} registros al servidor.\n\n"
                "• Accidentes: ${resultado['accidentes']}\n"
                "• Incidentes: ${resultado['incidentes']}\n"
                "• Gestiones: ${resultado['gestiones']}\n"
                "• Capacitaciones: ${resultado['capacitaciones']}\n"
                "• Enfermedades: ${resultado['enfermedades']}"
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar'))
                ],
              )
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error al sincronizar: $e"))
            );
          }
        }
      }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      /// AppBar con título y notificación
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

        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: "Sincronizar datos",
            onPressed: ejecutarSincronizacion,
          ),
          const SizedBox(width: 10,)
        ],
      ),

      /// Layout adaptable según ancho de pantalla
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
                    /// Título de sección
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

/// Grid de formularios
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
                        /// Tarjeta: Accidente
                        CardForm(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AccidenteFormScreen(),
                              ),
                            );
                          },
                          icono: Image.asset(
                            'assets/images/lesion-laboral.png',
                            height: 80,
                            width: 80,
                          ),
                          typeForm: "Accidente",
                        ),

                        /// Tarjeta: Incidente
                        CardForm(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const IncidenteFormScreen(),
                              ),
                            );
                          },
                          icono: Image.asset(
                            'assets/images/seguimiento.png',
                            height: 80,
                            width: 80,
                          ),
                          typeForm: "Incidente",
                        ),

                        /// Tarjeta: Enfermedad Laboral
                        CardForm(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EnfermedadFormScreen (),
                              ),
                            );
                          },
                          icono: Image.asset(
                            'assets/images/enfermedad.png',
                            height: 80,
                            width: 80,
                          ),
                          typeForm: "Enfermedad Laboral",
                        ),

                        /// Tarjeta: Capacitaciones
                        CardForm(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CapacitacionFormScreen(),
                              ),
                            );
                          },
                          icono: Image.asset(
                            'assets/images/capacitacion.png',
                            height: 80,
                            width: 80,
                          ),
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
