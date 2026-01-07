import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/accidente_providers.dart';
import 'accidente_detalle_screen.dart';

/// Pantalla que muestra el historial de accidentes reportados por el usuario actual.
///
/// Filtra la lista global de accidentes para mostrar solo los que pertenecen
/// al usuario autenticado en la sesion.
class AccidentesEnviadosScreen extends HookConsumerWidget {
  const AccidentesEnviadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cargar accidentes al iniciar la pantalla
    useEffect(() {
      Future.microtask(() {
        ref.read(accidenteNotifierProvider.notifier).loadAccidentes();
      });
      return null;
    }, []);

    // Obtener el usuario autenticado
    final usuarioActual = ref.watch(usuarioAutenticadoProvider);

    // Observar el estado de accidentes
    final accidenteState = ref.watch(accidenteNotifierProvider);

    final getProyectos = ref.read(getProyectosUseCaseProvider);
    final getContratistas = ref.read(getAllContratistasUseCaseProvider);

    final listaProyectos = useState<List<Map<String, dynamic>>>([]);
    final listaContratistas = useState<List<Map<String, dynamic>>>([]);

    useEffect(() {
      Future.microtask(() async {
        try {
          final proyectos = await getProyectos();
          listaProyectos.value = proyectos;

          final contratistas = await getContratistas();
          listaContratistas.value = contratistas;
        } catch (_) {}
      });
      return null;
    }, []);

    // Filtrar solo los accidentes del usuario actual
    final misAccidentes = usuarioActual != null
        ? accidenteState.accidentes
              .where((a) => a.usuarioId == usuarioActual.id)
              .toList()
        : <dynamic>[]; // Lista vacia si no hay usuario

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mis Formularios Enviados'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: accidenteState.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Cargando formularios...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : misAccidentes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No has enviado formularios aún',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tus reportes de accidentes aparecerán aquí',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER CON ESTADISTICAS ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Accidentes Reportados',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.assignment,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total: ${misAccidentes.length} reporte${misAccidentes.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- LISTA DE ACCIDENTES ---
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: misAccidentes.length,
                    itemBuilder: (context, index) {
                      final accidente = misAccidentes[index];
                      final fechaFormateada = DateFormat(
                        'dd/MM/yyyy',
                      ).format(accidente.fechaRegistro);

                      // Buscar nombre del proyecto usando el ID
                      String nombreProyecto = "ID: ${accidente.proyectoId}";
                      if (listaProyectos.value.isNotEmpty) {
                        try {
                          final p = listaProyectos.value.firstWhere(
                            (p) => p['id'] == accidente.proyectoId,
                          );
                          nombreProyecto =
                              p['Nombre'] ?? p['nombre'] ?? nombreProyecto;
                        } catch (_) {}
                      }

                      String nombreContratista =
                          "ID: ${accidente.contratistaId}";
                      if (listaContratistas.value.isNotEmpty) {
                        try {
                          final c = listaContratistas.value.firstWhere(
                            (c) => c['id'] == accidente.contratistaId,
                          );
                          nombreContratista =
                              c['Nombre'] ?? c['nombre'] ?? nombreContratista;
                        } catch (_) {}
                      }

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AccidenteDetalleScreen(
                                  accidente: accidente,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Encabezado con tipo y estado
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        accidente.eventualidad,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Fondo blanco
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: accidente.sincronizado == 1
                                              ? Colors
                                                    .green // Verde si esta completo
                                              : Colors
                                                    .red, // Rojo si esta incompleto
                                          width: 2.0, // Grosor del borde
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            accidente.sincronizado == 1
                                                ? Icons
                                                      .thumb_up_alt_outlined // Dedito arriba (Completo)
                                                : Icons
                                                      .circle_outlined, // Circulo (Incompleto)
                                            size: 16,
                                            color: accidente.sincronizado == 1
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            accidente.sincronizado == 1
                                                ? "Completa"
                                                : "Incompleta",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: accidente.sincronizado == 1
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Informacion del proyecto
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.business,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Proyecto: $nombreProyecto',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Contratista
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Contratista: $nombreContratista',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Fecha
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fecha: $fechaFormateada',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Boton de ver mas
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AccidenteDetalleScreen(
                                                accidente: accidente,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                    ),
                                    label: const Text('Ver detalles'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
