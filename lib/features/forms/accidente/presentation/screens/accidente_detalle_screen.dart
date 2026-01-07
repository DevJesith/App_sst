import 'package:app_sst/features/forms/accidente/presentation/providers/accidente_providers.dart';
import 'package:app_sst/features/forms/accidente/presentation/screens/accidente_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/accidente.dart';

class AccidenteDetalleScreen extends HookConsumerWidget {
  final Accidente accidente;

  const AccidenteDetalleScreen({super.key, required this.accidente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Formateo de fecha
    final fechaFormateada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(accidente.fechaRegistro);

    // 2. Estados locales para los nombres (Hooks)
    final nombreProyecto = useState<String>('Cargando...');
    final nombreContratista = useState<String>('Cargando...');

    // 3. Efecto para cargar los nombres reales basados en los IDs
    useEffect(() {
      Future<void> cargarNombres() async {
        try {
          // Obtenemos los casos de uso
          final getProyectos = ref.read(getProyectosUseCaseProvider);
          final getAllContratistas = ref.read(
            getAllContratistasUseCaseProvider,
          );

          // Ejecutamos las consultas en paralelo para mayor velocidad
          final resultados = await Future.wait([
            getProyectos(),
            getAllContratistas(),
          ]);

          final listaProyectos = resultados[0];
          final listaContratistas = resultados[1];

          // --- BUSCAR NOMBRE DEL PROYECTO ---
          try {
            final proyectoEncontrado = listaProyectos.firstWhere(
              (p) => p['id'] == accidente.proyectoId,
            );
            // Intentamos obtener 'Nombre' o 'nombre' por si acaso cambia la mayúscula en la BD
            nombreProyecto.value =
                proyectoEncontrado['Nombre'] ??
                proyectoEncontrado['nombre'] ??
                'Sin Nombre';
          } catch (_) {
            nombreProyecto.value = 'Desconocido (ID: ${accidente.proyectoId})';
          }

          // --- BUSCAR NOMBRE DEL CONTRATISTA ---
          try {
            final contratistaEncontrado = listaContratistas.firstWhere(
              (c) => c['id'] == accidente.contratistaId,
            );
            nombreContratista.value =
                contratistaEncontrado['Nombre'] ??
                contratistaEncontrado['nombre'] ??
                'Sin Nombre';
          } catch (_) {
            nombreContratista.value =
                'Desconocido (ID: ${accidente.contratistaId})';
          }
        } catch (e) {
          debugPrint("Error al cargar maestros: $e");
          nombreProyecto.value = "Error de carga";
          nombreContratista.value = "Error de carga";
        }
      }

      cargarNombres();
      return null;
    }, const []); // Se ejecuta una sola vez al montar el widget

    // 4. Logica para eliminar
    Future<void> confirmarEliminacion() async {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Eliminar reporte?'),
          content: const Text('Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        if (accidente.id == null) throw Exception("El ID es nulo");

        await ref
            .read(accidenteNotifierProvider.notifier)
            .eliminarAccidente(accidente.id!);

        if (context.mounted) {
          Navigator.of(context).pop(); // Cerrar loading
          Navigator.of(context).pop(); // Cerrar pantalla detalle
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Cerrar loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detalle del Accidente'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Solo permitimos editar/eliminar si NO está sincronizado
          if (accidente.sincronizado == 0) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar reporte',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AccidenteFormScreen(accidente: accidente),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar',
              onPressed: confirmarEliminacion,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
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
                  Text(
                    accidente.eventualidad,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      accidente.estado,
                      style: TextStyle(
                        color: _getEstadoColor(accidente.estado),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENIDO ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Tarjeta 1: Información General
                  _buildInfoCard(
                    title: 'Información General',
                    icon: Icons.info_outline,
                    children: [
                      // AQUI USAMOS LOS VALORES CARGADOS POR EL HOOK
                      _buildInfoRow('Proyecto', nombreProyecto.value),
                      _buildInfoRow('Contratista', nombreContratista.value),
                      _buildInfoRow('Mes', accidente.mes),
                      _buildInfoRow('Fecha Registro', fechaFormateada),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta 2: Descripción
                  _buildInfoCard(
                    title: 'Descripción',
                    icon: Icons.description_outlined,
                    children: [
                      Text(
                        accidente.descripcion,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta 3: Incapacidad
                  _buildInfoCard(
                    title: 'Incapacidad',
                    icon: Icons.medical_services_outlined,
                    children: [
                      _buildInfoRow(
                        'Días de Incapacidad',
                        '${accidente.diasIncapacidad} día${accidente.diasIncapacidad != 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta 4: Avances
                  _buildInfoCard(
                    title: 'Avances',
                    icon: Icons.timeline_outlined,
                    children: [
                      Text(
                        accidente.avances.isEmpty
                            ? 'Sin avances registrados'
                            : accidente.avances,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta 5: Sincronización
                  _buildInfoCard(
                    title: 'Sincronización',
                    icon: Icons.cloud_sync,
                    children: [
                      Row(
                        children: [
                          Icon(
                            accidente.sincronizado == 1
                                ? Icons.check_circle
                                : Icons.pending,
                            color: accidente.sincronizado == 1
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            accidente.sincronizado == 1
                                ? 'Sincronizado'
                                : 'Pendiente de envío',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: accidente.sincronizado == 1
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red.shade700, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'completado':
      case 'cerrado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
