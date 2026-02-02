import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// Imports
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/enfermedad_providers.dart';
import 'enfermedad_detalle_screen.dart';

/// Pantalla que muestra el historial de enfermedades laborales reportadas por el usuario actual.
///
/// Filtra la lista global de enfermedades para mostrar solo las que pertenecen
/// al usuario autenticado en la sesión.
class EnfermedadesEnviadosScreen extends HookConsumerWidget {
  const EnfermedadesEnviadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cargar enfermedades al iniciar la pantalla
    useEffect(() {
      Future.microtask(() {
        ref.read(enfermedadNotifierProvider.notifier).loadEnfermedad();
      });
      return null;
    }, []);

    // Obtener el usuario autenticado
    final usuarioActual = ref.watch(usuarioAutenticadoProvider);

    // Observar el estado de enfermedades
    final enfermedadState = ref.watch(enfermedadNotifierProvider);

    // Filtrar solo las enfermedades del usuario actual
    final misEnfermedades = usuarioActual != null
        ? enfermedadState.enfermedad
              .where((a) => a.usuarioId == usuarioActual.id)
              .toList()
        : <dynamic>[]; // Lista vacia si no hay usuario

    // --- LOGICA PARA OBTENER NOMBRES REALES ---
    final getProyectos = ref.read(getProyectosEnfermedadUseCaseProvider);
    final getContratistas = ref.read(
      getContratistasEnfermedadesUseCaseProvider,
    );
    final getTrabajadores = ref.read(getTrabajadoresEnfermedadUseCaseProvider);

    final proyectosCache = useState<Map<int, String>>({});
    final contratistasCache = useState<Map<int, String>>({});
    final trabajadoresCache = useState<Map<int, String>>({});

    // Cargar datos para el cache
    useEffect(() {
      Future.microtask(() async {
        try {
          final proyectos = await getProyectos();
          final proyectosMap = <int, String>{};
          for (var p in proyectos) {
            proyectosMap[p['id']] = p['Nombre'] ?? p['nombre'] ?? 'Sin nombre';
          }
          proyectosCache.value = proyectosMap;

          // Cargar contratistas y trabajadores para cada enfermedad
          for (var enfermedad in misEnfermedades) {
            final contratistas = await getContratistas(enfermedad.proyectoId);
            for (var c in contratistas) {
              contratistasCache.value[c['id']] =
                  c['Nombre'] ?? c['nombre'] ?? 'Sin nombre';
            }

            final trabajadores = await getTrabajadores(
              enfermedad.proyectoId,
              enfermedad.contratistaId,
            );
            for (var t in trabajadores) {
              trabajadoresCache.value[t['id']] =
                  t['Nombres'] ?? t['nombres'] ?? 'Sin nombre';
            }
          }
        } catch (e) {
          debugPrint('Error cargando caché de nombres: $e');
        }
      });
      return null;
    }, [misEnfermedades.length]);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mis Formularios Enviados'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: enfermedadState.isLoading
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
              : misEnfermedades.isEmpty
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
                        'Tus reportes de enfermedades aparecerán aquí',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER CON ESTADÍSTICAS ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enfermedades Reportadas',
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
                                'Total: ${misEnfermedades.length} reporte${misEnfermedades.length != 1 ? 's' : ''}',
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
          
                    // --- LISTA DE ENFERMEDADES ---
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: misEnfermedades.length,
                        itemBuilder: (context, index) {
                          final enfermedad = misEnfermedades[index];
                          final fechaFormateada = DateFormat(
                            'dd/MM/yyyy',
                          ).format(enfermedad.fechaRegistro);
          
                          // Obtener nombres del caché
                          final nombreProyecto =
                              proyectosCache.value[enfermedad.proyectoId] ??
                              'ID: ${enfermedad.proyectoId}';
                          final nombreContratista =
                              contratistasCache.value[enfermedad.contratistaId] ??
                              'ID: ${enfermedad.contratistaId}';
                          final nombreTrabajador =
                              trabajadoresCache.value[enfermedad.trabajadorId] ??
                              'ID: ${enfermedad.trabajadorId}';
          
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
                                    builder: (_) => EnfermedadDetalleScreen(
                                      enfermedad: enfermedad,
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
                                            enfermedad.eventualidad,
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
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: enfermedad.sincronizado == 1
                                                  ? Colors.green
                                                  : Colors.red,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                enfermedad.sincronizado == 1
                                                    ? Icons.thumb_up_alt_outlined
                                                    : Icons.circle_outlined,
                                                size: 16,
                                                color: enfermedad.sincronizado == 1
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                enfermedad.sincronizado == 1
                                                    ? "Completa"
                                                    : "Incompleta",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      enfermedad.sincronizado == 1
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
          
                                    // Información del proyecto
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
          
                                    // Trabajador
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Trabajador: $nombreTrabajador',
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
                                                  EnfermedadDetalleScreen(
                                                    enfermedad: enfermedad,
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
        ),
      ),
    );
  }
}
